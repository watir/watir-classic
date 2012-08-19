module Watir
  class ModalDialog
    include Container
    include PageContainer
    include Win32

    def initialize(container)
      set_container container
      @modal = ::RAutomation::Window.new(:hwnd=>@container.hwnd).child(:class => 'Internet Explorer_TridentDlgFrame')
    end

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

    def title
      document.title
    end

    def close(timeout=5)
      return unless exists?
      document.parentWindow.close
      Watir::Wait.until(timeout) {!exists?} rescue nil
      wait
    end

    def attach_command
      "Watir::IE.find(:hwnd, #{@container.hwnd}).modal_dialog"
    end

    def wait(no_sleep=false)
      @container.page_container.wait unless exists?
    end

    def hwnd
      @modal.hwnd
    end

    def active?
      @modal.active?
    end

    def exists?
      @modal.exists?
    end

    alias_method :exist?, :exists?

  end
end
