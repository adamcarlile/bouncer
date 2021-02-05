require 'bouncer/strategies/shared/profile'

module Bouncer
  module Strategies
    class Stub < ::Warden::Strategies::Base
      def valid?
        mocked? && mocked_user
      end

      def store?
        !Bouncer.config.api_mode
      end

      def authenticate!
        user = Bouncer::User.new({
          profile: profile,
          session: {
            token:      Bouncer::Tokens::Plain.new(jwt_token),
            expires_at: expires_at,
            checked_at: checked_at
          }
        })

        session['redirect_to'] = '/'

        success! user
      end

      private

      def jwt_token
        @jwt_token ||= ::JWT.encode payload, nil, 'none'
      end

      def profile
        payload.slice *Shared::Profile::ATTRS
      end

      def payload
        {
          "sub" => mocked_user[:id],
          "name" => mocked_user[:name],
          "email" => mocked_user[:email],
          "exp" => expires_at,
          "iat" => Time.now.to_i,
          "kid" => SecureRandom.uuid
        }
      end

      def mocked?
        mock_config.enabled
      end

      def mocked_user
        mock_config.user
      end

      def expires_at
        mock_config.expires_at.call.to_i
      end

      def checked_at
        mock_config.checked_at.call.to_i
      end

      def mock_config
        Bouncer.config.mock
      end

      def development?
        (ENV['RAILS_ENV'] || ENV['RACK_ENV']) == 'development'
      end

    end
  end
end
