module Watir
  class Map < NonControlElement
    TAG = 'MAP'
  end

  class Area < NonControlElement
    TAG = 'AREA'
  end

  module Container
    def map(how, what)
      return Map.new(self, how, what)
    end
    def area(how, what)
      return Area.new(self, how, what)
    end
  end
end