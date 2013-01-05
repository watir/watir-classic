# watir-classic/browser
require 'watir-classic/options'
module Watir
  
=begin rdoc

Watir is a family of open-source drivers for automating web browsers. You
can use it to write tests that are easy to read and maintain. 

Watir drives browsers the same way people do. It clicks links, fills in forms,
presses buttons. Watir also checks results, such as whether expected text 
appears on a page.

The Watir Classic is a driver for Internet Explorer (on Windows).

Project Homepage: http://watir.com

@example usage

  require 'watir-classic'
  browser = Watir::Browser.new
  browser.goto 'http://google.com'
  browser.text_field(:name => 'q').set 'pickaxe'  
  browser.button(:name => 'btnG').click
  if browser.text.include? 'Programming Ruby'
    puts 'Text was found'
  else
    puts 'Text was not found'
  end

=end rdoc
  
  class Browser
    # @private
    @@browser_classes = {}

    # @private
    @@sub_options = {}

    # @private
    @@default = nil

    class << self

      # Create a new instance of the {Browser} object
      # @param [Object] ignored Argument is only needed to make
      #   watir-classic more compatible with watir-webdriver and is really ignored.
      def new(ignored=nil)
        set_sub_options
        klass.new
      end

      # Create a new {Browser} instance as with {.new} and start the browser on the
      # specified url.
      # @param [String] url Url to start the browser at.
      def start(url)
        set_sub_options
        klass.start url
      end

      # Attach to an existing IE {Browser}.
      #
      # @example Attach with full title:
      #   Watir::Browser.attach(:title, "Full title of IE")
      #
      # @example Attach with part of the title using {Regexp}:
      #   Watir::Browser.attach(:title, /part of the title of IE/)
      #
      # @example Attach with part of the url:
      #   Watir::Browser.attach(:url, /google/)
      #
      # @example Attach with window handle:
      #   Watir::Browser.attach(:hwnd, 123456)
      #
      # @param [Symbol] how type of the locator. Can be :title, :url or :hwnd.
      # @param [Symbol] what value of the locator. Can be {String}, {Regexp} or {Fixnum}
      #   depending of the type parameter.
      def attach(how, what)
        set_sub_options
        klass.attach(how, what)
      end
      
      # Set options for the {Browser}.
      def set_options(options)
        return unless klass.respond_to?(:set_options)
        klass.set_options options
      end

      # @return [Hash] options of the {Browser}.
      def options
        return {} unless klass.respond_to?(:options)
        klass.options
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
      # @todo remove this and autoloading since now only IE is supported.
      # @private
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
      
      # @private
      def default
        @@default
      end

      # Specifies a default browser. Must be specified before options are parsed.
      # @todo remove this since only IE is supported.
      # @private
      def default= option
        @@default = option
      end

      # Returns the names of the browsers that are supported by this module.
      # These are the options for 'watir_browser' (env var) or 'browser:' (yaml).
      # @todo remove this since only IE is supported.
      # @private
      def browser_names
        @@browser_classes.keys
      end      
      
      private

      # @todo remove this since only IE is supported.
      def autoload class_string, library
        mod, klass = class_string.split('::')
        eval "module ::#{mod}; autoload :#{klass}, '#{library}'; end"
      end

      # Activate the gem (if installed). The default browser will be set
      # to the first gem that activates.
      # @todo remove this since only IE is supported.
      def activate_gem gem_name, option
        begin
          gem gem_name 
          @@default ||= option
        rescue Gem::LoadError
        end
      end

      # @todo remove this since only IE is supported.
      def set_sub_options
        sub_options = @@sub_options[Watir.options[:browser]]
        return if sub_options.nil?
        specified_options = Watir.options.reject {|k, v| !sub_options.include? k}
        self.set_options specified_options
      end
    end
  end

end

require 'watir-classic/browsers'
