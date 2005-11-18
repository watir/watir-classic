# feature tests for JavaScript events
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_JSEvents < Test::Unit::TestCase
    include Watir

    
    def gotoJavaScriptEventsPage()
        $ie.goto($htmlRoot + "javascriptevents.html")
    end

  
    def test_Button_disabled
       gotoJavaScriptEventsPage()
       assert_false($ie.button(:caption, "Button 1").enabled?) 
    end

    def test_Button_Enabled
       gotoJavaScriptEventsPage()    
     
       $ie.text_field(:name, "entertext").fire_event("onkeyup")
       assert($ie.button(:caption, "Button 1").enabled?)   
     
    end

    def test_Button_click

       gotoJavaScriptEventsPage()
       
       puts "Firing event to make button enabled"
       $ie.text_field(:name, "entertext").fire_event("onKeyUp")
       puts "Clicking the button"

       $ie.button(:caption, "Button 1").click
       assert($ie.text.include?("PASS") )
    end

#onMouseOver tests
 #window status

    def test_no_status_bar_exception
        gotoJavaScriptEventsPage()
        $ie.link(:text, "New Window No Status Bar").click
        status_bar_test_win = nil
        assert_nothing_raised { status_bar_test_win = Watir::IE.attach(:title, "Pass Page") }
        assert_raises( Watir::NoStatusBarException ) { status_bar_test_win.status }
        status_bar_test_win.close
        status_bar_test_win = nil

    end

    
    def test_page_nostatus
       gotoJavaScriptEventsPage()
       assert_false($ie.status == "Here is your status") 
    end
  
    def test_page_status
       gotoJavaScriptEventsPage()
       $ie.link(:text, "Check the Status").fire_event("onMouseOver")
       assert($ie.status, "It worked") 
    end
    
    def test_page_status
       gotoJavaScriptEventsPage()
       $ie.link(:text, "Clear the Status").fire_event("onMouseOver")
       assert($ie.status, "") 
    end
 #end of window status

#end of onMouseOver tests

end

