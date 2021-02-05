module Bouncer
  module Tokens
    class Encrypted

      delegate :payload, :header, :expires_at, :issued_at, :issuer, to: :jwt

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
          type: :encrypted
        }
      end
      
      private

      def jwt
        @jwt ||= ::Bouncer::JWT::Payload.parse(decoded_token)
      end

      def decoded_token
        @decoded_token ||= begin
          raise Bouncer::JWT::MissingKeysetError if Bouncer.keyset.blank?
          ::JWT.decode(@token, nil, true, { algorithms: [Bouncer.config.jwt.algorithms].flatten, jwks: Bouncer.keyset })
        end
      end

    end
  end
end