require 'bouncer/strategies/shared/profile'

module Bouncer
  module Strategies
    class Token < ::Warden::Strategies::Base
      def valid?
        auth.provided? && auth.valid?
      end

      def store?
        false
      end

      def authenticate!
        user = Bouncer::User.new({
         profile: profile,
          session: {
            token: encrypted_token,
            checked_at: DateTime.now
          }
        })

        fail!('Invalid user') and return unless user.valid?

        success! user
      rescue ::JWT::ExpiredSignature, ::JWT::DecodeError => e
        fail!(e.message)
      rescue Bouncer::JWT::MissingKeysetError => e
        Bouncer.reset_keyset_cache!
        fail!(e.message)
      end

      private

      def profile
        @profile ||= encrypted_token.payload.slice *Shared::Profile::ATTRS
      end

      def encrypted_token
        @token ||= Bouncer::Tokens::Encrypted.new(auth.params)
      end

      def auth
        @auth ||= Rack::Auth::AbstractRequest.new(env)
      end
    end
  end
end
