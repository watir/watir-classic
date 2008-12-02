require 'watir/win32ole'
require 'watir/ie' # for Watir.autoit

class WindowHelper
    @@ie_window_name = "Windows Internet Explorer"
    def initialize()
        @autoit = Watir.autoit
    end
    
    def push_alert_button
        @autoit.WinWait @@ie_window_name, ""
        @autoit.Send "{ENTER}"
    end
    
    def push_confirm_button_ok
        @autoit.WinWait @@ie_window_name, ""
        @autoit.Send "{ENTER}"
    end
    
    def push_confirm_button_cancel
        @autoit.WinWait @@ie_window_name, ""
        @autoit.Send "{ESCAPE}"
    end
    
    def push_security_alert_yes
        @autoit.WinWait "Security Alert", ""
        @autoit.Send "{TAB}"
        @autoit.Send "{TAB}"
        @autoit.Send "{SPACE}"
    end
        
    def logon(title,name = 'john doe',password = 'john doe')
        @autoit.WinWait title, ""
        @autoit.Send name
        @autoit.Send "{TAB}"
        @autoit.Send password
        @autoit.Send "{ENTER}"
    end
    
    def WindowHelper.check_autoit_installed
        begin
          Watir.autoit
        rescue
            raise Watir::Exception::WatirException, "The AutoIt dll must be correctly registered for this feature to work properly"
        end
    end
end


