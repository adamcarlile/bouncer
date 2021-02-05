module Bouncer
  module Tokens
    class Plain
      delegate :payload, :header, to: :jwt

      attr_reader :token

      def initialize(token)
        @token = token
      end

      def valid?
        decoded_token.present?
      end

      def as_json(*)
        {
          token: @token,
          type: :plain
        }
      end

      private

      def jwt
        @jwt ||= ::Bouncer::JWT::Payload.parse(decoded_token)
      end

      def decoded_token
        @decoded_token ||= ::JWT.decode(@token, nil, false)
      end

    end
  end
end