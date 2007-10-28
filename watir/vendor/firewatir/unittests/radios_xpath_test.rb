# feature tests for Radio Buttons
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Radios_XPath < Test::Unit::TestCase
    include FireWatir

    def setup()
        $ff.goto($htmlRoot + "radioButtons1.html")
    end
   
    def test_Radio_Exists
       assert($ff.radio(:xpath, "//input[@name='box1']").exists?)   
       assert($ff.radio(:xpath, "//input[@id='box5']").exists?)   

       assert_false($ff.radio(:xpath, "//input[@name='missingname']").exists?)   
       assert_false($ff.radio(:xpath, "//input[@id='missingid']").exists?)   
    end

    def test_Radio_Enabled
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='noName']").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@id='noName']").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='box4' and @value='6']").enabled?  }  

       assert_false($ff.radio(:xpath, "//input[@name='box2']").enabled?)   
       assert($ff.radio(:xpath, "//input[@id='box5']").enabled?)   
       assert($ff.radio(:xpath, "//input[@name='box1']").enabled?)   
    end

   def test_little
       assert_false($ff.button(:xpath,"//input[@name='foo']").enabled?)
   end

   def test_onClick
       assert_false($ff.button(:xpath,"//input[@name='foo']").enabled?)          
       $ff.radio(:xpath, "//input[@name='box5' and @value='1']").set
       assert($ff.button(:xpath,"//input[@name='foo']").enabled?)        

       $ff.radio(:xpath, "//input[@name='box5' and @value='2']").set
       assert_false($ff.button(:xpath,"//input[@name='foo']").enabled?)
    end

    def test_Radio_isSet
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='noName']").isSet?  }  

       puts "radio 1 is set : #{ $ff.radio(:xpath, "//input[@name='box1']").isSet? } "
       assert_false($ff.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert($ff.radio(:xpath, "//input[@name='box3']").isSet?)   
       assert_false($ff.radio(:xpath, "//input[@name='box2']").isSet?)   

       assert( $ff.radio(:xpath, "//input[@name='box4' and @value='1']").isSet?)   
       assert_false($ff.radio(:xpath, "//input[@name='box4' and @value='2']").isSet?)   
    end

    def test_radio_clear
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='noName']").clear  }  

       $ff.radio(:xpath, "//input[@name='box1']").clear
       assert_false($ff.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='box2']").clear  } 
       assert_false($ff.radio(:xpath, "//input[@name='box2']").isSet?)   

       $ff.radio(:xpath, "//input[@name='box3']").clear
       assert_false($ff.radio(:xpath, "//input[@name='box3']").isSet?)   

       $ff.radio(:xpath, "//input[@name='box4' and @value='1']").clear
       assert_false($ff.radio(:xpath, "//input[@name='box4' and @value='1']").isSet?)   
    end

    def test_radio_getState
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='noName']").getState  }  

       assert_equal( false , $ff.radio(:xpath, "//input[@name='box1']").getState )   
       assert_equal( true , $ff.radio(:xpath, "//input[@name='box3']").getState)   

       # radioes that have the same name but different values
       assert_equal( false , $ff.radio(:xpath, "//input[@name='box4' and @value='2']").getState )   
       assert_equal( true , $ff.radio(:xpath, "//input[@name='box4' and @value='1']").getState)   
    end

    def test_radio_set
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='noName']").set  }  
       $ff.radio(:xpath, "//input[@name='box1']").set
       assert($ff.radio(:xpath, "//input[@name='box1']").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ff.radio(:xpath, "//input[@name='box2']").set  }  

       $ff.radio(:xpath, "//input[@name='box3']").set
       assert($ff.radio(:xpath, "//input[@name='box3']").isSet?)   

       # radioes that have the same name but different values
       $ff.radio(:xpath, "//input[@name='box4' and @value='3']").set
       assert($ff.radio(:xpath, "//input[@name='box4' and @value='3']").isSet?)   
    end

end

