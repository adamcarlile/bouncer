module Bouncer
  class Token < Virtus::Attribute
    COERCABLE_TYPES = {
      encrypted: Bouncer::Tokens::Encrypted,
      plain: Bouncer::Tokens::Plain
    }
    
    def coerce(value)
      return value unless value.is_a? ::Hash
      COERCABLE_TYPES[value['type'].to_sym].new(value['token'])
    end
  end
end