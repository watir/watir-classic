module Watir
  class Alert
    include ElementExtensions

    WINDOW_TITLES = ['Message from webpage', 'Windows Internet Explorer', 'Microsoft Internet Explorer', /Mensaje de p.*/, "Explorer User Prompt"]

    def initialize(container)
      @container = container
    end

    def exists?
      dialog.present?
    end

    alias_method :present?, :exists?

    def close
      dialog.close
      wait_until_not_exists
    end

    def text
      dialog.text
    end

    def ok
      dialog.button(:value => "OK").click
      wait_until_not_exists
    end

    def set(text)
      dialog.text_field.set text
    end

    private 

    def dialog
      @window ||= RAutomation::Window.new(:hwnd => @container.hwnd).child(:title => /^(#{WINDOW_TITLES.join('|')})$/)
    end

    def wait_until_not_exists
      Wait.until(3) {!exists?}
      @container.page_container.wait
    end
  end
end
