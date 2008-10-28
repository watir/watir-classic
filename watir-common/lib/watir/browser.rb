# watir/browser
require 'watir/options'
module FireWatir
  autoload :Firefox, 'firewatir'
end

module Watir
  autoload :IE, 'watir'
  
  module Browser
    @@browser_classes = {
      'ie' => 'Watir::IE', 
      'firefox' => 'FireWatir::Firefox'
    }
    class << self
      def new *args
        klass.new *args
      end
      def start *args
        klass.start *args
      end
      def klass
        key = Watir.options[:browser]
        eval @@browser_classes[key] # this triggers the autoload
      end
    end
  end

end