# feature tests for Radio Buttons
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Radios_XPath < Test::Unit::TestCase
    

    def setup()
        goto_page("radioButtons1.html")
    end
   
    def test_Radio_Exists
       assert(browser.radio(:xpath, "//input[@name='box1']").exists?)   
       assert(browser.radio(:xpath, "//input[@id='box5']").exists?)   

       assert_false(browser.radio(:xpath, "//input[@name='missingname']").exists?)   
       assert_false(browser.radio(:xpath, "//input[@id='missingid']").exists?)   
    end

    def test_Radio_Enabled
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='noName']").enabled?  }  
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@id='noName']").enabled?  }  
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='box4' and @value='6']").enabled?  }  

       assert_false(browser.radio(:xpath, "//input[@name='box2']").enabled?)   
       assert(browser.radio(:xpath, "//input[@id='box5']").enabled?)   
       assert(browser.radio(:xpath, "//input[@name='box1']").enabled?)   
    end

   def test_little
       assert_false(browser.button(:xpath,"//input[@name='foo']").enabled?)
   end

   def test_onClick
       assert_false(browser.button(:xpath,"//input[@name='foo']").enabled?)          
       browser.radio(:xpath, "//input[@name='box5' and @value='1']").set
       assert(browser.button(:xpath,"//input[@name='foo']").enabled?)        

       browser.radio(:xpath, "//input[@name='box5' and @value='2']").set
       assert_false(browser.button(:xpath,"//input[@name='foo']").enabled?)
    end

    def test_Radio_isSet
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='noName']").isSet?  }  

       puts "radio 1 is set : #{ browser.radio(:xpath, "//input[@name='box1']").isSet? } "
       assert_false(browser.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert(browser.radio(:xpath, "//input[@name='box3']").isSet?)   
       assert_false(browser.radio(:xpath, "//input[@name='box2']").isSet?)   

       assert( browser.radio(:xpath, "//input[@name='box4' and @value='1']").isSet?)   
       assert_false(browser.radio(:xpath, "//input[@name='box4' and @value='2']").isSet?)   
    end

    def test_radio_clear
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='noName']").clear  }  

       browser.radio(:xpath, "//input[@name='box1']").clear
       assert_false(browser.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   browser.radio(:xpath, "//input[@name='box2']").clear  } 
       assert_false(browser.radio(:xpath, "//input[@name='box2']").isSet?)   

       browser.radio(:xpath, "//input[@name='box3']").clear
       assert_false(browser.radio(:xpath, "//input[@name='box3']").isSet?)   

       browser.radio(:xpath, "//input[@name='box4' and @value='1']").clear
       assert_false(browser.radio(:xpath, "//input[@name='box4' and @value='1']").isSet?)   
    end

    def test_radio_getState
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='noName']").getState  }  

       assert_equal( false , browser.radio(:xpath, "//input[@name='box1']").getState )   
       assert_equal( true , browser.radio(:xpath, "//input[@name='box3']").getState)   

       # radioes that have the same name but different values
       assert_equal( false , browser.radio(:xpath, "//input[@name='box4' and @value='2']").getState )   
       assert_equal( true , browser.radio(:xpath, "//input[@name='box4' and @value='1']").getState)   
    end

    def test_radio_set
       assert_raises(UnknownObjectException) {   browser.radio(:xpath, "//input[@name='noName']").set  }  
       browser.radio(:xpath, "//input[@name='box1']").set
       assert(browser.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   browser.radio(:xpath, "//input[@name='box2']").set  }  

       browser.radio(:xpath, "//input[@name='box3']").set
       assert(browser.radio(:xpath, "//input[@name='box3']").isSet?)   

       # radioes that have the same name but different values
       browser.radio(:xpath, "//input[@name='box4' and @value='3']").set
       assert(browser.radio(:xpath, "//input[@name='box4' and @value='3']").isSet?)   
    end

end

