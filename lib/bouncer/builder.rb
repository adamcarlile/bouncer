class Bouncer::Builder
  class << self

    attr_reader :options

    def new(app, opts = {})
      @options = default_options.merge(opts)

      extract_options!
      validate_config!

      oauth.setup! unless @options[:api_mode]
      warden.setup!

      builder.run(Bouncer::Middleware.new(app, @options))
      builder
    end

    def extract_options!
      oauth.tap do |x|
        x.id      = options[:oauth][:id]
        x.secret  = options[:oauth][:secret]
        x.host    = options[:oauth][:host]
        x.options = options[:oauth][:options]
      end
      warden.tap do |x|
        x.api_mode       = options[:api_mode]
        x.session_secret = options[:warden][:session_secret]
        x.strategies     = options[:warden][:strategies]
        x.failure_app    = options[:warden][:failure_app]
        x.intercept_401  = options[:warden][:intercept_401]
      end
    end

    def validate_config!
      logger.warn('OAuth not configured correctly, expecting :id, :secret') if !options[:api_mode] && oauth.valid?
    end

    def builder
      @builder ||= ::Rack::Builder.new
    end

    def default_options
      {
        oauth:  {},
        warden: {}
      }
    end

    def oauth
      @oauth ||= Bouncer::OAuth.new(builder)
    end

    def warden
      @warden ||= Bouncer::Warden.new(builder)
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

  end

end
