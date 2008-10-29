require 'watir/ie'

module Watir
  class IE
    # close all ie browser windows
    def self.close_all
      close_all_but nil
    end
    # find other ie browser windows and close them
    def close_others
      IE.close_all_but self
    end
    private
    def self.close_all_but(except=nil)
      Watir::IE.each do |ie|
        ie.close_modal
        ie.close unless except and except.hwnd == ie.hwnd
      end
      sleep 1.0 # replace with polling for window count to be zero?
    end
    public
    # close modal dialog. unlike IE#modal_dialog.close, does not wait for dialog
    # to appear and does not raise exception if no window is found.
    # returns true if modal was found and close, otherwise false
    def close_modal
      begin
        original_attach_timeout = IE.attach_timeout
        IE.attach_timeout = 0
        self.modal_dialog.close
        true
      rescue NoMatchingWindowFoundException, TimeOutException
        false
      ensure
        IE.attach_timeout = original_attach_timeout
      end
    end
  end
end