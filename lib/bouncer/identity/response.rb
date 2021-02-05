module Bouncer
  module Identity
    class Response
      extend Forwardable

      def_delegators :response, :success?, :status

      attr_reader :path, :provider
      def initialize(path, provider)
        @path     = path
        @provider = provider
      end

      def body
        @body ||= OpenStruct.new(JSON.parse(response.body || '{}', symbolize_names: true))
      end

      def to_hash
        body.to_h
      end

      def unauthorized?
        response.status.to_i == 401
      end

      private

        def response
          @response ||= begin
            provider.get(path)
          rescue => e
            Faraday::Response.new(body: {error: e.to_s}.to_json, status: 520)
          end
        end

    end
  end
end