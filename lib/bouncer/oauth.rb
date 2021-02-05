class Bouncer::OAuth

  attr_accessor :id, :secret, :host, :options

  delegate :hostname, :scheme, :port, to: :uri

  def initialize(builder)
    @builder = builder
  end

  def setup!
    local_options = client_options
    @builder.use OmniAuth::Builder do
      provider :identity, local_options
    end
  end

  def valid?
    id && secret && host
  end

  def client
    @client ||= OAuth2::Client.new(id, secret, {site: host})
  end

  def client_options
    options.deep_merge({
      issuer: host,
      discovery: true,
      client_auth_method: :jwks,
      client_options: {
        identifier: id,
        secret: secret,
        host: hostname,
        port: port,
        scheme: scheme
      }
    })
  end

  private

    def uri
      @uri ||= URI.parse(host)
    end

end
