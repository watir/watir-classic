class WinClicker
  def initialize
    raise NotImplementedError, 'Watir no longer supports WinClicker. Please use click_no_wait and the javascript_dialog method.'
  end
end

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
      intUnknown = 0
      begin
        Watir::until_with_timeout do
          intPointer = " " * 4 # will contain the int value of the IUnknown*
          GetUnknown.call(hwnd, intPointer)
          intArray = intPointer.unpack('L')
          intUnknown = intArray.first
          intUnknown > 0
        end
      rescue Wait::TimeoutError => e
        raise NoMatchingWindowFoundException,
          "Unable to attach to Modal Window after #{e.duration} seconds."
      end
      @document = WIN32OLE.connect_unknown(intUnknown)
    end

    def document
      locate
      @document
    end
    
    def title
      document.title
    end

    def close
      document.parentWindow.close
    end

    def attach_command
      "Watir::IE.find(:hwnd, #{@container.hwnd}).modal_dialog"
    end
      
    def wait(no_sleep=false)
      sleep 1
      if exists?
        # do nothing
      else
        @container.page_container.wait
      end
    end
    
    def hwnd
      @modal.hwnd
    end

    def active?
      @modal.active?
    end

    # When checking to see if the modal exists we give it some time to
    # find it. So if it does see a modal it returns immediately, otherwise it waits and checks
    def exists?(timeout=5)
      begin
        Watir::Wait.until(timeout) {@modal.exists?}
      rescue Watir::Wait::TimeoutError
      end
      return @modal.exists?
    end
    alias :exist? :exists?
  end
end