module Watir

  class JavascriptDialog
    WINDOW_TITLES = ['Message from webpage', 'Windows Internet Explorer','Microsoft Internet Explorer',/Mensaje de p.*/]

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

    def text
      javascript_dialog_window.text
    end

    def javascript_dialog_window
      @window ||= ::RAutomation::Window.new(:title => @opts[:title] || /^(#{WINDOW_TITLES.join('|')})$/)
    end

    Watir::Container.module_eval do
      def javascript_dialog(opts={})
        JavascriptDialog.new(opts)
      end

      alias_method :dialog, :javascript_dialog
    end
  end
end





