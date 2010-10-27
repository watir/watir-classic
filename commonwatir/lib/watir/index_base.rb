module Watir
  @@index_base = 1 # default, for now
  class << self
    def index_base
      @@index_base
    end
    # Set the origin for :index. Values 0 or 1 are supported.
    def index_base= integer
      @@index_base = integer
    end
  end
end