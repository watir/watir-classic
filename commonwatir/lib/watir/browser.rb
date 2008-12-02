# watir/browser
require 'watir/options'
module Watir
  
=begin rdoc

Watir is a family of open-source drivers for automating web browsers. You
can use it to write tests that are easy to read and maintain. 

Watir drives browsers the same way people do. It clicks links, fills in forms,
presses buttons. Watir also checks results, such as whether expected text 
appears on a page.

The Watir family currently includes support for Internet Explorer (on Windows),
Firefox (on Windows, Mac and Linux) and Safari (on Mac). 

Project Homepage: http://wtr.rubyforge.org

This Browser module provides a generic interface
that tests can use to access any browser. The actual browser (and thus
the actual Watir driver) is determined at runtime based on configuration
settings.

  require 'watir'
  browser = Watir::Browser.new
  browser.goto 'http://google.com'
  browser.text_field(:name, 'q').set 'pickaxe'  
  browser.button(:name, 'btnG').click
  if browser.text.include? 'Programming Ruby'
    puts 'Text was found'
  else
    puts 'Text was not found'
  end

A comprehensive summary of the Watir API can be found here
http://wiki.openqa.org/display/WTR/Methods+supported+by+Element

There are two ways to configure the browser that will be used by your tests.

One is to set the +watir_browser+ environment variable to +ie+ or +firefox+. 
(How you do this depends on your platform.)

The other is to create a file that looks like this.

  browser: ie

And then to add this line to your script, after the require statement and 
before you invoke Browser.new.

  Watir.options_file = 'path/to/the/file/you/just/created'

=end rdoc
  
  module Browser
    @@browser_classes = {}
    @@sub_options = {}
    @@default = nil
    class << self

      # Create a new instance of a browser driver, as determined by the
      # configuration settings. (Don't be fooled: this is not actually 
      # an instance of Browser class.)
      def new
        set_sub_options
        klass.new
      end
      # Create a new instance as with #new and start the browser on the
      # specified url.
      def start url
        set_sub_options
        klass.start url
      end
      def klass
        key = Watir.options[:browser]
        eval @@browser_classes[key] # this triggers the autoload
      end
      private :klass
      # Add support for the browser option, using the specified class, 
      # provided as a string. Optionally, additional options supported by
      # the class can be specified as an array of symbols. Options specified
      # by the user and included in this list will be passed (as a hash) to 
      # the set_options class method (if defined) before creating an instance.
      def support hash_args
        option = hash_args[:name]
        class_string = hash_args[:class]
        additional_options = hash_args[:options]
        library = hash_args[:library]
        gem = hash_args[:gem] || library

        @@browser_classes[option] = class_string        
        @@sub_options[option] = additional_options

        autoload class_string, library
        activate_gem gem, option
      end
      def autoload class_string, library
        mod, klass = class_string.split('::')
        eval "module ::#{mod}; autoload :#{klass}, '#{library}'; end"
      end
      # Activate the gem (if installed). The default browser will be set
      # to the first gem that activates.
      def activate_gem gem_name, option
        begin
          gem gem_name 
          @@default ||= option
        rescue Gem::LoadError
        end
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