##
# Unique random strings

module Borges::ExternalID

  DEFAULT_LENGTH = 8
  INIT_ARR = ('a'...'z').to_a + ('A'...'Z').to_a

  def self.create(length = DEFAULT_LENGTH)
    eid = ''

    length.times do eid << INIT_ARR[rand(INIT_ARR.size)] end

    return eid.intern
  end

end # class ExternalID

