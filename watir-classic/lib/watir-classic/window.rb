module Watir
  class Window
    include ElementExtensions

    class << self
      attr_accessor :__main_ie

      def wrap *meths
        meths.each do |meth|
          define_method meth do
            result = nil
            use {result = browser.send(meth)}
            result
          end
        end
      end
    end

    def initialize(main_browser, locators, browser=nil, &blk)
      valid_locators = [:title, :url, :hwnd, :index]
      locators.each_pair do |k, v| 
        raise ArgumentError, "Valid locators are #{valid_locators.join(", ")}" unless valid_locators.include?(k)
      end
      @main_browser = main_browser
      self.class.__main_ie = main_browser.ie
      @locators = locators
      @browser = browser
    end

    wrap :url, :title, :hwnd, :close

    def browser
      @browser ||= begin
                    IE.find(@locators.keys.first, @locators.values.first)
                   end
    end

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

    def current?
      @main_browser.hwnd == browser.hwnd && @main_browser.html == browser.html
    end

    def ==(other)
      browser.hwnd == other.hwnd && browser.html == other.browser.html
    end

    alias_method :eql?, :==

    def present?
      @browser = nil
      browser && browser.exists?
    end

  end
end
