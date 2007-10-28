$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_JavaScript_Test < Test::Unit::TestCase
    include FireWatir
#    include FireWatir::Dialog
    
    def setup
        $ff.goto($htmlRoot  + 'JavascriptClick.html')
    end
    
    def test_alert
        #$ff.button(:id, "btnAlert").click_no_wait()

        #$ff.click_jspopup_button("OK")
        $ff.startClicker("ok", 1, '', "Press OK")
        $ff.button(:id, "btnAlert").click

        assert_equal($ff.text_field(:id, "testResult").value , "You pressed the Alert button!")
        assert_equal("Press OK", $ff.get_popup_text)
        
        $ff.startClicker("ok")
        $ff.button(:id, "btnAlert").click

        assert_equal($ff.text_field(:id, "testResult").value , "You pressed the Alert button!")
        assert_equal("Press OK", $ff.get_popup_text)
    end
    
    def test_confirm_ok
        #$ff.button(:id, "btnConfirm").click_no_wait()
        
        #$ff.click_jspopup_button("OK")
        $ff.startClicker("ok", 1, '', "Press a button")
        $ff.button(:id, "btnConfirm").click

        assert_equal($ff.text_field(:id, "testResult").value , "You pressed the Confirm and OK button!")
        assert_equal("Press a button", $ff.get_popup_text)

        $ff.startClicker("ok")
        $ff.button(:id, "btnConfirm").click

        assert_equal($ff.text_field(:id, "testResult").value , "You pressed the Confirm and OK button!")
        assert_equal("Press a button", $ff.get_popup_text)
    end
    
    def test_confirm_cancel
        #$ff.button(:id, "btnConfirm").click_no_wait()
        
        #$ff.click_jspopup_button("Cancel")
        $ff.startClicker("cancel", 1, '', "Press a button")
        $ff.button(:id, "btnConfirm").click

        assert_equal($ff.text_field(:id, "testResult").value, "You pressed the Confirm and Cancel button!")
        assert_equal("Press a button", $ff.get_popup_text)

        $ff.startClicker("cancel")
        $ff.button(:id, "btnConfirm").click

        assert_equal($ff.text_field(:id, "testResult").value, "You pressed the Confirm and Cancel button!")
        assert_equal("Press a button", $ff.get_popup_text)
    end

    def test_ok_selectbox
        $ff.goto($htmlRoot + "selectboxes1.html")
        $ff.startClicker("ok")
        $ff.select_list(:id , "selectbox_5").select_value(/2/)

        assert_equal($ff.text_field(:id, "txtAlert").value , "You pressed OK button")
        assert_equal("Press OK", $ff.get_popup_text)
    end
end
