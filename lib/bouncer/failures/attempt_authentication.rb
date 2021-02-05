module Bouncer
  module Failures
    class AttemptAuthentication
      
      def self.call(env)
        new(env).call
      end

      attr_reader :req, :res
      def initialize(env)
        @req = Rack::Request.new(env)
        @res = Rack::Response.new
      end

      def call
        res.redirect("/auth/identity?redirect_to=#{return_to}")
        res.finish
      end

      def return_to
        req.cookies['bouncer.return_to'] || req.env['ORIGINAL_FULLPATH']
      end

    end
  end
end
