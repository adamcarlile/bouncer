module Bouncer
  module Identity
    extend self

    def config
      @config ||= {
        host: Bouncer.config.oauth.host
      }
    end

    def links
      @links ||= OpenStruct.new.tap do |x|
        x.full_logout_path = "/auth/logout"
        x.auth_url         = "#{config[:host]}"
        x.logout_url       = "#{config[:host]}/sessions/destroy"
      end
    end

    def configure &block
      yield(config)
    end

    def client(token = nil)
      Identity::Client.new(config.dup.merge({ token: token }))
    end

  end
end