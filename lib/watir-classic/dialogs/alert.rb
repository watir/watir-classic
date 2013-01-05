module Watir
  # Handle different JavaScript dialogs (alert, prompt and confirm).
  # Returned by {Container#alert}.
  class Alert
    include ElementExtensions

    # JavaScript dialog titles to search for.
    #
    # @example When the title of your IE dialog is missing, add a new one:
    #   Watir::Alert::WINDOW_TITLES << "My missing title"
    WINDOW_TITLES = ['Message from webpage', 'Windows Internet Explorer', 'Microsoft Internet Explorer', /Mensaje de p.*/, "Explorer User Prompt"]

    def initialize(container)
      @container = container
    end

    # @return [Boolean] true when JavaScript dialog exists and is visible, false otherwise.
    def exists?
      dialog.present?
    end

    alias_method :present?, :exists?

    # Close the JavaScript dialog.
    def close
      dialog.close
      wait_until_not_exists
    end

    # @return [String] the visible text of the JavaScript dialog.
    def text
      dialog.text
    end

    # Press the "OK" button on the JavaScript dialog.
    def ok
      dialog.button(:value => "OK").click
      wait_until_not_exists
    end

    # Set the text on the JavaScript prompt dialog.
    # @param [String] text text to set.
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
