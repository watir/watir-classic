module Watir
  
  module Browser
    @@klass = nil
    class << self
      def new *args
        @@klass.new *args
      end
      def start *args
        @@klass.start *args
      end
    end
  end
end