class Bouncer::Session
  include Virtus.model

  attribute :token, Bouncer::Token
  attribute :refresh, String
  attribute :checked_at, DateTime

  delegate :valid?, :payload, :header, to: :token 

  def refreshable?
    refresh.present?
  end

  def refresh!
    return unless refreshable?
    oauth_token.refresh!.tap do |new_token|
      self.token      = token_class.new(new_token.token)
      self.refresh    = new_token.refresh_token
      self.checked_at = Time.now.utc.to_i
    end
    @decoded_token  = nil
    self
  end

  def access_token
    token.token
  end

  def current?
    within_grace_period? || token_current?
  end

  private

  def within_grace_period?
    checked_at.present? && grace_period < checked_at
  end

  def token_current?
    if client.token_info.success?
      self.checked_at = Time.now.utc
    else
      false
    end
  end

  def grace_period
    60.seconds.ago
  end

  def token_class
    token.class
  end

  def oauth_token
    OAuth2::AccessToken.new(Bouncer::Builder.oauth.client, access_token, { refresh_token: refresh })
  end

  def client
    Bouncer::Identity::Client.new(host: Bouncer.config.oauth.host, token: access_token)
  end

end
