Fabricator(:session, class_name: 'bouncer/session') do
  token             { Bouncer::Tokens::Plain.new(SecureRandom.hex(10)) }
  refresh           { SecureRandom.hex(10) }
  checked_at        { Time.now }
end