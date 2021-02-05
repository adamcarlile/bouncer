class Bouncer::User
  include Virtus.model

  attribute :profile, Hash
  attribute :session, Bouncer::Session

  delegate :valid?, :access_token, to: :session

  def email
    profile['email']
  end

  def id
    profile['sub']
  end

  def name
    profile['name']
  end

  def as_json(*args)
    {
      profile: profile,
      session: session.as_json(*args)
    }.reject {|k, v| v.blank? }
  end

end
