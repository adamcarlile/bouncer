class Bouncer::Warden

  attr_writer :session_secret, :strategies, :failure_app, :intercept_401, :api_mode

  def initialize(builder)
    @builder = builder
  end

  def setup!
    @builder.use(Rack::Session::Cookie, secret: session_secret) unless defined?(RailsWarden)
    @builder.use warden_manager do |manager|
      manager.failure_app = failure_app
      manager.intercept_401 = @intercept_401

      default_strategies = []

      if Bouncer.mocked?
        Warden::Strategies.add :stub, Bouncer::Strategies::Stub
        default_strategies << :stub
      end

      if Bouncer.config.api_mode
        Warden::Strategies.add :token, Bouncer::Strategies::Token
        default_strategies << :token
      else
        Warden::Strategies.add :omniauth, Bouncer::Strategies::Omniauth
        default_strategies << :omniauth
      end

      default_strategies << @strategies

      manager.default_strategies default_strategies.compact

      Warden::Manager.serialize_into_session do |user|
        user.as_json
      end

      Warden::Manager.serialize_from_session do |attrs|
        Bouncer::User.new attrs
      end
    end
  end

  def session_secret
    @session_secret || 'supersekret'
  end

  def failure_app
    @failure_app || default_failure_app
  end

  def warden_manager
    defined?(RailsWarden) ? RailsWarden::Manager : Warden::Manager
  end

  private

  def default_failure_app
    @api_mode ? Bouncer::Failures::RenderJSON : Bouncer::Failures::AttemptAuthentication
  end

end
