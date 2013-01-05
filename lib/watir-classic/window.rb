module Watir
  # Returned by {IE#window}.
  class Window
    include ElementExtensions

    class << self
      # @private
      attr_accessor :__main_ie

      # @private
      def wrap(*meths)
        meths.each do |meth|
          define_method meth do
            result = nil
            use {result = browser.send(meth)}
            result
          end
        end
      end
    end

    def initialize(main_browser, locators, browser=nil)
      valid_locators = [:title, :url, :hwnd, :index]
      locators.each_pair do |k, v| 
        raise ArgumentError, "Valid locators are #{valid_locators.join(", ")}" unless valid_locators.include?(k)
      end
      @main_browser = main_browser
      self.class.__main_ie = main_browser.ie
      @locators = locators
      @browser = browser
    end

    # @!method url
    #   @return [String] url of the {Window}.
    # @!method title
    #   @return [String] title of the {Window}.
    # @!method hwnd
    #   @return [Fixnum] handle of the {Window}.
    # @!method close
    #   Close the {Window}.
    wrap :url, :title, :hwnd, :close

    # @return [Browser] browser of the window.
    def browser
      @browser ||= begin
                    IE.find(@locators.keys.first, @locators.values.first)
                   end
    end

    # Use the window.
    #
    # @example Change current window:
    #   browser.window(:title => /foo/).use
    #   browser.title # => "foo"
    #
    # @example Execute code in the other window:
    #   browser.window(:title => /foo/).use do
    #     browser.title # => "foo"
    #   end
    #   browser.title # => "current window title"
    #
    # @yield optional block in the context of new {Window}.
    def use(&blk)
      @main_browser.ie = browser.ie
      if blk
        begin
          blk.call
        ensure
          @main_browser.ie = self.class.__main_ie
          # try to find some existing IE when needed
          @main_browser.ie = IE._find(:index, 0) unless @main_browser.exists?
        end
      end
      self
    end

    # @return [Boolean] true when {Window} is the active {Browser} instance,
    #   false otherwise
    def current?
      @main_browser.hwnd == browser.hwnd && @main_browser.html == browser.html
    end

    def ==(other)
      browser.hwnd == other.hwnd && browser.html == other.browser.html
    end

    alias_method :eql?, :==

    # @return [Boolean] true when {Window} browser exists, false otherwise.
    def present?
      @browser = nil
      browser && browser.exists?
    end

  end
end
