module Bouncer
  module Strategies
    class Omniauth < ::Warden::Strategies::Base

      def valid?
        !env['omniauth.auth'].nil?
      end

      def authenticate!
        auth = env['omniauth.auth']

        user = Bouncer::User.new({
          profile: auth['extra']['raw_info'],
          session: {
            token:      Bouncer::Tokens::Encrypted.new(auth['credentials']['token']),
            refresh:    auth['credentials']['refresh_token'],
            expires_at: auth['credentials']['expires_at'],
            checked_at: Time.now.utc.to_i
          }
        })

        fail!("Invalid user") and return unless user.valid?

        session['redirect_to'] = redirect_to

        success! user
      end

      private

        def redirect_to
          env['omniauth.params']['redirect_to'] || '/'
        end

    end
  end
end
