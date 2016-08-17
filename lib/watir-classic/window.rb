module Watir
  # Returned by {Browser#window}.
  
  Point = Struct.new(:x, :y)
  Dimension = Struct.new(:width, :height)
  
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
                    Browser.find(@locators.keys.first, @locators.values.first)
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
          @main_browser.ie = Browser._find(:index, 0) unless @main_browser.exists?
        end
      end
      self
    end

    # @return [Boolean] true when {Window} is the active {Browser} instance,
    #   false otherwise
    def current?
      @main_browser.hwnd == browser.hwnd && @main_browser.html == browser.html
    end

    # @return [Boolean] true when {Window} browser exists, false otherwise.
    def present?
      @browser = nil
      browser && browser.exists?
    end

    def ==(other)
      browser.hwnd == other.hwnd && browser.html == other.browser.html
    end

    alias_method :eql?, :==

    #
    # Returns window size.
    #
    # @example
    # size = browser.window.size
    # [size.width, size.height] #=> [1600, 1200]
    #

    def size
      dimensions = browser.rautomation.dimensions
      Dimension.new(dimensions[:width], dimensions[:height])
    end

    #
    # Returns window position.
    #
    # @example
    # position = browser.window.position
    # [position.x, position.y] #=> [92, 76]
    #

    def position
      dimensions = browser.rautomation.dimensions
      Point.new(dimensions[:left], dimensions[:top])
    end

    #
    # Resizes window to given width and height.
    #
    # @example
    # browser.window.resize_to 1600, 1200
    #
    # @param [Fixnum] width
    # @param [Fixnum] height
    #

    def resize_to(width, height)
      browser.rautomation.move(width: width, height: height)
      size
    end

    #
    # Moves window to given x and y coordinates.
    #
    # @example
    # browser.window.move_to 300, 200
    #
    # @param [Fixnum] x
    # @param [Fixnum] y
    #

    def move_to(x, y)
      browser.rautomation.move(left: x, top: y)
      position
    end

    #
    # Maximizes window.
    #
    # @example
    # browser.window.maximize
    #

    def maximize
      browser.rautomation.maximize
    end

  end
end
