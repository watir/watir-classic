module Watir

  class JavascriptDialog
    WINDOW_TITLES = ['Message from webpage', 'Windows Internet Explorer','Microsoft Internet Explorer']

    attr_accessor :timeout

    def initialize(opts={})
      @opts = opts
      @timeout = 30
    end

    def exists?
      javascript_dialog_window.exists?
    end

    def button(value)
      javascript_dialog_window.button(:value => value)
    end

    def close
      javascript_dialog_window.close
    end

    def text
      javascript_dialog_window.text
    end

    def javascript_dialog_window
      return @window if @window
      RAutomation::Window.wait_timeout = @timeout
      if @opts[:title]
        @window = ::RAutomation::Window.new(:title => @opts[:title])
      else
        @window = ::RAutomation::Window.new(:title => /^(#{WINDOW_TITLES.join('|')})$/)
      end
      @window
    end

  end
end





