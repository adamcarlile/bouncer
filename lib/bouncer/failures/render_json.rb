module Bouncer
  module Failures
    class RenderJSON
      
      def self.call(env)
        new(env).call
      end

      attr_reader :req, :res
      def initialize(env)
        @req = Rack::Request.new(env)
        @res = Rack::Response.new
      end

      def call
        res.content_type = "application/json"
        res.status = 401
        res.write({ error: 'Unauthorized', message: message }.to_json)
        res.finish
      end

      private

      def message
        warden.message || "Unable to authenticate"
      end

      def warden
        req.env['warden']
      end

    end
  end
end
