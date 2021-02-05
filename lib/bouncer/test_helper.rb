module Bouncer
  module TestHelpers
    def default_bouncer_config
      {
        oauth: {
          id: '46307a2b-0397-4739-b2b7-2f67d1cff597',
          secret: '46307a2b-0397-4739-b2b7-2f67d1cff597'
        }
      }
    end

    def app_host
      Rack::Test::DEFAULT_HOST
    end

    def app
      @app
    end

    def follow_successful_oauth!(fetched_user_info = {})
      # Ensure we've got a fake valid session
      allow_any_instance_of(Bouncer::Session).to receive(:current?).and_return(true)
      # (OAuth dance starts)
      user_info = default_fetched_user_info.merge!(fetched_user_info)
      uid = user_info.delete('id')

      credentials = { token:'12345', refresh_token:'67890' }

      ::OmniAuth.config.mock_auth[:test_provider] =
        ::OmniAuth::AuthHash.new(
          provider: 'test_provider',
          credentials: credentials,
          info: user_info,
          uid: uid
        )

      # Stub API response
      struct = OpenStruct.new(body: OpenStruct.new(user_info))
      allow(Identity::Client).to receive(:new).and_return(struct)
    end

    def default_fetched_user_info
      { 'email' => 'joe@a.com', 'id' => '123' }
    end

    def assert_redirected_to_path(path)
      expect(last_response.status).to eq 302
      expect(URI.parse(last_response.location).path).to eq(path), 'Missing redirection to #{path}'
    end

    def assert_requires_authentication
      expect(last_response.location).to eq("http://#{app_host}/"), "Authentication expected, wasn't required"
    end

    def authorize_user!(email: 'john.smith@example.com', id: '1')
      ::Bouncer.configure do |config|
        config.mock.enabled = true
        config.mock.user = { email: email, id: id }
      end
    end

    def unauthorize_user!
      ::Bouncer.configure do |config|
        config.mock.enabled = false
        config.mock.user = nil
      end
    end
  end
end
