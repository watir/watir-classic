#TODO: work around rautomation persistently hitting the button
# should be able to handle any dialog but defaults to standard dialogs
# need docs
module Watir
  def javascript_dialog(opts={})
    JavascriptDialog.new(opts)
  end

  class JavascriptDialog
    WINDOW_TITLES = ['Message from webpage', 'Windows Internet Explorer','Microsoft Internet Explorer']

    def initialize(opts={})
      @opts = opts
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

    def javascript_dialog_window
      return @window if @window
      RAutomation::Window.wait_timeout = 5
      if @opts[:title]
        @window = Watir::Dialog::Window.new(:title => opts[:title])
      else
        @window = ::RAutomation::Window.new(:title => /^(#{WINDOW_TITLES.join('|')})$/)
      end
      @window
    end

  end
end





