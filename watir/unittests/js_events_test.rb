# tests for JavaScript events
# revision: $Revision$

require 'unittests/setup'

class TC_JSEvents < Test::Unit::TestCase

#button enabled/disabled tests
    def gotoJavaScriptEventsPage()
        $ie.goto($htmlRoot + "javascriptevents.html")
    end

  
    def test_Button_disabled
       gotoJavaScriptEventsPage()
       assert_false($ie.button(:caption, "Button 1").enabled?) 
    end

    def test_Button_Enabled
       gotoJavaScriptEventsPage()    
     
       $ie.textField(:name, "entertext").fireEvent("onkeyup")
       assert($ie.button(:caption, "Button 1").enabled?)   
     
    end

    def test_Button_click

       gotoJavaScriptEventsPage()
       
       puts "Firing event to make button enabled"
       $ie.textField(:name, "entertext").fireEvent("onKeyUp")
       puts "Clicking the button"

       $ie.button(:caption, "Button 1").click
       assert($ie.pageContainsText("PASS") )
    end
   


end

