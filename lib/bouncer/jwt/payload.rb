module Bouncer
  module JWT
    class Payload
      class << self
        def parse(jwt)
          new(payload: jwt.first, header: jwt.last)
        end
      end
      include Virtus.model

      attribute :payload, ActiveSupport::HashWithIndifferentAccess
      attribute :header, ActiveSupport::HashWithIndifferentAccess

      def key_id
        header["kid"]
      end

      def algorithm
        header["alg"]
      end

      def expires_at
        Time.at(payload["exp"]) if payload["exp"]
      end

      def issued_at
        Time.at(payload["iat"]) if payload["iat"]
      end

      def issuer
        payload["iss"]
      end

    end
  end
end
