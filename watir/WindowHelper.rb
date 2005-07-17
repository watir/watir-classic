require 'win32ole'

class WindowHelper
    def initialize( )
        @autoit = WIN32OLE.new('AutoItX3.Control')
    end
    
    def push_alert_button()
        @autoit.WinWait "Microsoft Internet Explorer", ""
        @autoit.Send "{ENTER}"
    end
    
    def push_confirm_button_ok()
        @autoit.WinWait "Microsoft Internet Explorer", ""
        @autoit.Send "{ENTER}"
    end
    
    def push_confirm_button_cancel()
        @autoit.WinWait "Microsoft Internet Explorer", ""
        @autoit.Send "{ESCAPE}"
    end
    
    def push_security_alert_yes()
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
            WIN32OLE.new('AutoItX3.Control')
        rescue
            raise Watir::Exception::WatirException, "The AutoIt dll must be correctly registered for this feature to work properly"
        end
    end
end


