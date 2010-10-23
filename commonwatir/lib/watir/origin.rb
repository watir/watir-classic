module Watir
  class << self
    def origin
      @@origin
    end
    # Set the origin for :index. Values 0 or 1 are supported.
    def origin= integer
      @@origin = integer
    end
  end
end