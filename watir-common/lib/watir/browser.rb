# watir/browser
require 'watir/options'
module Watir
  module Browser
    @@browser_classes = {}
    @@sub_options = {}
    @@default = 'ie'
    class << self
      def new
        set_sub_options
        klass.new
      end
      def start url
        set_sub_options
        klass.start url
      end
      def klass
        key = Watir.options[:browser]
        eval @@browser_classes[key] # this triggers the autoload
      end
      # Add support for the browser option, using the specified class, 
      # provided as a string. Optionally, additional options supported by
      # the class can be specified as an array of symbols. Options specified
      # by the user and included in this list will be passed (as a hash) to 
      # the set_options class method (if defined) before creating an instance.
      def support option, class_string, additional_options=[]
        @@browser_classes[option] = class_string        
        @@sub_options[option] = additional_options
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
      def set_sub_options
        return unless defined?(klass.set_options)
        sub_options = @@sub_options[Watir.options[:browser]]
        specified_options = Watir.options.reject {|k, v| !sub_options.include? k}
        klass.set_options specified_options
      end
    end
  end

end

require 'watir/browsers'