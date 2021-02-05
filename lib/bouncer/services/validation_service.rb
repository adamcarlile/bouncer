module Bouncer
  module Services
    class ValidationService < ServiceObject

      attr_reader :warden

      def initialize(warden, options)
        @warden, @options = warden, options
      end

      def run
        return fire(:success, user) if session.valid? && session.current?
        fire :failure, user
      rescue ::JWT::DecodeError => e
        return fire(:failure) unless session.refreshable?
        begin
          session.refresh!
          run
        rescue OAuth2::Error => e
          fire :failure
        rescue Faraday::ConnectionFailed, Errno::ECONNREFUSED => e
          fire :success, user
        end
      end
      
      private

        def session
          user.session
        end

        def user
          @user ||= warden.user
        end

    end
  end
end
