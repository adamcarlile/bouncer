module Bouncer
  module OmniAuth
    class IdentityStrategy < ::OmniAuth::Strategies::OpenIDConnect
      option :name, :identity

      option :scope, [:openid, :profile, :email]

      option :discovery, true

      def redirect_uri
        full_host + script_name + callback_path   
      end

    end
  end
end

OmniAuth::Strategies::Identity = Bouncer::OmniAuth::IdentityStrategy
