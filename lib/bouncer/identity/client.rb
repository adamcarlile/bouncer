module Bouncer
  module Identity
    class Client

      attr_reader :token, :host
      def initialize(config)
        @token   = config[:token]
        @host    = config[:host]
      end

      def token_info
        Identity::Response.new('/oauth/token/info.json', provider)
      end

      def jwks
        Identity::Response.new('/.well-known/jwks.json', provider)
      end

      private

        def provider
          @provider ||= Faraday.new(url: host) do |faraday|
            faraday.headers['Content-Type'] = 'application/json'
            faraday.headers['Authorization'] = "Bearer #{token}" if token

            faraday.adapter Faraday.default_adapter
          end
        end
    
    end
  end
end
