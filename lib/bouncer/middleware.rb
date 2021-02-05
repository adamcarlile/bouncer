class Bouncer::Middleware < Sinatra::Base
  enable :raise_errors
  disable :show_exceptions

  def initialize(app, options = {})
    if options[:api_mode]
      @app = app
      @disabled = true
    else
      @options = options
      super(app)
    end
  end

  def call(env)
    if @disabled
      @app.call(env)
    else
      super(env)
    end
  end

  before do
    if env['warden'].authenticated?
      Bouncer::Services::ValidationService.run!(env['warden'], @options) do |on|
        on.success do |user|
          env['warden'].set_user(user)
        end
        on.failure do
          env['warden'].logout and return
        end
      end
    end
  end

  get '/auth/identity/callback' do
    user = env['warden'].authenticate!
    redirect(session.delete('redirect_to') || '/')
  end

  get '/auth/logout' do
    env['warden'].logout
    redirect(redirect_uri)
  end

  private

    def redirect_uri
      URI.parse(auth_url).tap do |uri|
        uri.path = '/sessions/destroy'
        uri.query = params.slice('redirect_uri').to_query unless params[:redirect_uri].blank?
      end
    end

    def oauth_options
      @options[:oauth] || {}
    end

    def auth_url
      oauth_options[:host] || Bouncer::Identity.links.auth_url
    end
end
