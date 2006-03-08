$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'
require 'watir/winClicker'

class TC_JavaScript_Test < Test::Unit::TestCase
    include Watir
    
    def setup
        $ie.goto($htmlRoot  + 'JavascriptClick.html')
    end
    
    def test_alert
        $ie.button(:id, "btnAlert").click_no_wait()
        
        if($ie.jspopup_appeared("Press OK"))
            puts "Javascript alert appeared"
            $ie.click_jspopup_button("OK")
            assert_equal($ie.text_field(:id, "testResult").value , "You pressed the Alert button!")
        else
            puts "No Javascript alert was shown."
        end
    end
    
    def test_confirm_ok
        $ie.button(:id, "btnConfirm").click_no_wait()
        
        if($ie.jspopup_appeared("Press a button"))
            puts "Javascript confirm dialog appeared"
            $ie.click_jspopup_button("OK")
            assert_equal($ie.text_field(:id, "testResult").value , "You pressed the Confirm and OK button!")
        else
            puts "No Javascript confirm dialog appeared"
        end
    end
    
    def test_confirm_cancel
        $ie.button(:id, "btnConfirm").click_no_wait()
        
        if($ie.jspopup_appeared("Press a button"))
            puts "Javascript confirm dialog appeared"
            $ie.click_jspopup_button("Cancel")
            assert_equal($ie.text_field(:id, "testResult").value, "You pressed the Confirm and Cancel button!")
        else
            puts "No Javascript confirm dialog appeared"
        end
    end
end