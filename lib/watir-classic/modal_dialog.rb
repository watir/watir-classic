module Watir
  # Returned by {Container#modal_dialog}.
  class ModalDialog
    include Container
    include PageContainer
    include Win32

    def initialize(container)
      set_container container
      @modal = ::RAutomation::Window.new(:hwnd => @container.hwnd).child(:class => 'Internet Explorer_TridentDlgFrame')
    end

    # @return [String] title of the dialog.
    def title
      document.title
    end

    # Close the modal dialog.
    #
    # @param [Fixnum] timeout timeout in seconds to wait until modal dialog is
    #   successfully closed.
    def close(timeout=5)
      return unless exists?
      document.parentWindow.close
      Watir::Wait.until(timeout) {!exists?} rescue nil
      wait
    end

    # @return [Fixnum] window handle of the dialog.
    def hwnd
      @modal.hwnd
    end

    # @return [Boolean] true when modal window is active/in focus, false otherwise.
    def active?
      @modal.active?
    end

    # @return [Boolean] true when dialog exists, false otherwise.
    def exists?
      @modal.exists?
    end

    alias_method :exist?, :exists?

    # @private
    def locate
      @modal.wait_until_present rescue raise NoMatchingWindowFoundException

      intUnknown = 0
      Wait.until do
        intPointer = " " * 4 # will contain the int value of the IUnknown*
        GetUnknown.call(hwnd, intPointer)
        intArray = intPointer.unpack('L')
        intUnknown = intArray.first
        intUnknown > 0
      end
      
      WIN32OLE.connect_unknown(intUnknown)
    rescue NoMatchingWindowFoundException, Wait::TimeoutError
      raise NoMatchingWindowFoundException,
        "Unable to attach to Modal Window."
    end

    alias_method :document, :locate

    # @private
    def attach_command
      "Watir::IE.find(:hwnd, #{@container.hwnd}).modal_dialog"
    end

    # @private
    def wait(no_sleep=false)
      @container.page_container.wait unless exists?
    end

  end
end
