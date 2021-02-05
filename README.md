# Bouncer

Bouncer is designed to provide a middleware for either automatically performing the `OAuth` dance with the identity service and persisting that access token into the local applications session. Along with managing it's life cycle, and performing token refreshes provided a refresh token has been provided. 

Alternatively it can function in an `api_mode` where it will expect an `authentication_token` to be passed in the `Authorization` header in the `Authorization: Bearer <token>` format. Either raising a 401 or providing an authenticated `env['warden'].user` to the current action. It will not perform automatic refreshes, that's down to the calling application.

## Installation Instructions
### Rails

```ruby
gem 'bouncer'
gem 'rails_warden' #Requried to interface with the Rails session
```
- [rails_warden](https://github.com/hassox/rails_warden)

```ruby
# Normal installation
Bouncer.build! do |config|
  config.oauth.host     = 'http://id.example.com'
  config.oauth.id       = 'identity_application_id'
  config.oauth.secret   = 'identity_application_secret'
end

# To run in a mocked mode: IE defaulting all tokens to the user specified without
# contacting Identity at all
Bouncer.build! do |config|
  config.mock.enabled = true
  config.mock.user = { email: 'adam.carlile@example.com', id: '10' }
end

# Bouncer also allows the following additional configuration directives
Bouncer.build! do |config|
  config.mock.expires_at = ->() { 10.years.from_now }
  config.mock.checked_at = ->() { Time.now }

  config.oauth.options  = {}

  config.warden.session_secret = nil
  config.warden.strategies = []
  config.warden.failure_app = nil
  config.warden.intercept_401 = true

  config.jwt.keyset_loader = -> { Bouncer::Identity.client.jwks }
  config.jwt.algorithms    = ['RS256']
end
```

### Rack

Bouncer is compatible with Rack, however it needs the `config.api_mode` directive to be true. It's only designed to parse the `Authorization: Bearer <token>` header into `env['warden'].user # Bouncer::User`.

Authentication will fail if the JWT has expired, or is invalid for any other reason. It will then trigger the built in JSON response failure app, however you're encouraged to use your own specific failure application `config.warden.failure_app`

```ruby
gem 'bouncer'
```

```ruby
require 'sinatra'
require 'sinatra/json'
require 'bouncer'

Bouncer.configure do |config|
  config.api_mode   = true
  config.oauth.host = 'http://localhost:5000'
end

use Bouncer, Bouncer.config

get '/' do
  env['warden'].authenticate!
  json env['warden'].user.as_json
end
```
### Example

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate!

  def current_user
    return unless warden.user
    @current_user ||= User.find_or_create_by(email: warden.user.email)
  end
  helper_method :current_user

end
```

## Usage

Bouncer provides a `Bouncer::User` instance in the `warden.user` variable. 
It's up to you to decide how you want to decorate this. 
Either bind it to a local represetnation in your own database with permissions etc, or just use it as is.

```ruby
warden.user.valid?        # Boolean (if the current session is valid)
warden.user.access_token  # String (the complete access token, used for API requests)
warden.user.id            # String
warden.user.email         # String
warden.user.name          # String
warden.user.profile       # Hash (contains all the data from the OIDC exchange)
```

If refresh tokens are provided by the identity service, then Bouncer will consume those tokens and attempt to refresh the users session automatically without you having to do anything

Bouncer will also check the token validity once every 60 seconds, to ensure that once someone has logged out, we can successfully revoke their current session. Without waiting for the session expiry to complete

Bouncer will not perform the above checks if it's configured in `api_mode`

## Testing

In your `spec_helper.rb`:
```ruby
config.include Bouncer::TestHelpers, type: :feature
Warden.test_mode!
OmniAuth.config.test_mode = true
```

This activates test modes in Warden/OmniAuth/Bouncer. It will also give you these helpers in `feature` specs:
- `follow_successful_oauth!`: simulate a full, successful OAuth handshake
- `assert_requires_authentication`: assert that you have been bounced to SSO
- `assert_redirected_to_path`: assert that you have been redirected to a particular path after successfully authenticating
- `authorize_user!`: mock a user
- `unauthorize_user!`: remove the mocked user

### Example

```ruby
RSpec.describe 'I can log in' do
  let(:user_attributes) { { email: 'test@test.com' } }
  
  before(:each) do
    follow_successful_oauth!(user_attributes)
  end
  
  it 'show my details' do
    visit account_path
    expect(page).to have_selector '#email', text: 'test@test.com'
  end
end
```

```ruby
RSpec.describe 'I access an endpoint' do
  let(:user_attributes) { { email: 'test@test.com' } }

  def app
    @_app ||= Rack::Builder.new do |builder|
      builder.use Bouncer, Bouncer.config
      builder.run Api::Application
    end
  end

  before(:each) do
    authorize_user! email: user_attributes[email])
  end

  after(:each) do
    unauthorize_user!
  end

  it 'allows to access a protected endpoint' do
    get '/my-amazing-endpoint'

    expect(last_response.status).to eq(200)
  end
end
```
