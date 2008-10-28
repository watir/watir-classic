# watir/browser
require 'watir/options'
module Watir
  module Browser
    @@browser_classes = {}
    @@default = 'ie'
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
      # Add support for the browser option, using the specified class, 
      # provided as a string.
      def support option, class_string
        @@browser_classes[option] = class_string        
      end
      def default
        @@default
      end
      # Specifies a default browser. Must be specified before options are parsed.
      def default= option
        @@default = option
      end
      def options
        @@browser_classes.keys
      end
    end
  end

end

require 'watir/browsers'