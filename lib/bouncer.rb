require 'rack/builder'
require 'warden'
require 'virtus'
require 'active_support'
require 'active_support/core_ext'
require 'rails_warden' if defined?(Rails)
require 'omniauth-oauth2'
require 'omniauth_openid_connect'
require 'jwt'
require 'sinatra/base'
require 'faraday'

require 'bouncer/omniauth/identity_strategy'

require 'bouncer/identity'
require 'bouncer/identity/client'
require 'bouncer/identity/response'
require 'bouncer/test_helper'
require 'bouncer/services/service_object'
require 'bouncer/services/validation_service'
require 'bouncer/jwt/payload'
require 'bouncer/tokens/encrypted'
require 'bouncer/tokens/plain'
require 'bouncer/token'
require 'bouncer/session'
require 'bouncer/user'
require 'bouncer/builder'
require 'bouncer/middleware'
require 'bouncer/failures/attempt_authentication'
require 'bouncer/failures/render_json'
require 'bouncer/oauth'
require 'bouncer/warden'
require 'bouncer/strategies/omniauth'
require 'bouncer/strategies/stub'
require 'bouncer/strategies/token'

# $:.unshift File.expand_path('../lib', __FILE__)
module Bouncer
  class JWT::MissingKeysetError < StandardError; end

  module_function

  def new(*args)
    Bouncer::Builder.new(*args)
  end

  def build!(&block)
    configure(&block)
    mock! if mocked?
    attach_middleware!
  end

  def configure(&block)
    yield(config)
    post_configure!
  end

  def mock!
    config.warden.strategies = [:stub]
  end

  def mocked?
    config.mock.enabled
  end

  def keyset
    @keyset ||= begin
      response = config.jwt.keyset_loader.call()
      response.success? ? response.body.to_h : nil 
    end
  end

  def reset_keyset_cache!
    @keyset = nil
  end

  def config
    @config ||= ActiveSupport::OrderedOptions.new.tap do |config|
      config.api_mode   = false
      config.mock = ActiveSupport::OrderedOptions.new.tap do |mock|
        mock.enabled    = false
        mock.user       = { email: 'adam.carlile@checkatrade.com', id: '10', name: 'Adam Carlile' }
        mock.expires_at = ->() { 10.years.from_now }
        mock.checked_at = ->() { Time.now }
      end
      config.oauth = ActiveSupport::OrderedOptions.new.tap do |oauth|
        oauth.host    = ENV.fetch("IDENTITY_AUTH_URL") { "http://localhost:3000" }
        oauth.id      = nil
        oauth.secret  = nil
        oauth.options = {}
      end
      config.warden = ActiveSupport::OrderedOptions.new.tap do |warden|
        warden.session_secret = nil
        warden.strategies     = []
        warden.failure_app    = nil
        warden.intercept_401  = true
      end
      config.jwt = ActiveSupport::OrderedOptions.new.tap do |jwt|
        jwt.keyset_loader = -> { Bouncer::Identity.client.jwks }
        jwt.algorithms    = ['RS256']
      end
    end
  end

  def attach_middleware!
    Rails.application.config.middleware.insert_after ActionDispatch::Flash, ::Bouncer, config if defined?(Rails)
  end

  def post_configure!
    uri_builder = uri_builders[URI.parse(config.oauth.host).scheme]
    SWD.url_builder                         = uri_builder
    WebFinger.url_builder                   = uri_builder
    OpenIDConnect.validate_discovery_issuer = true
  end

  def uri_builders
    {
      'http'  => URI::HTTP,
      'https' => URI::HTTPS
    }
  end

end
