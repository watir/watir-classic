# feature tests for Check Boxes
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_CheckBox < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "checkboxes1.html")
    end

    def test_onClick
       assert_false($ie.button("foo").enabled?)
       $ie.checkBox(:name, "box5").set
       assert($ie.button("foo").enabled?)

       $ie.checkBox(:name, "box5").clear
       assert_false($ie.button("foo").enabled?)
    end

    def test_CheckBox_Exists
       assert($ie.checkBox(:name, "box1").exists?)   
       assert_false($ie.checkBox(:name, "missing").exists?)   

       assert($ie.checkBox(:name, "box4" , 1).exists?)   
       assert_false($ie.checkBox(:name, "box4" , 22).exists?)   
    end

    def test_CheckBox_Enabled
       assert_raises(UnknownObjectException) { $ie.checkBox(:name, "noName").enabled? }  
       assert_raises(UnknownObjectException) { $ie.checkBox(:id, "noName").enabled? }  
       assert_raises(UnknownObjectException) { $ie.checkBox(:name, "box4" , 6).enabled? }  

       assert($ie.checkBox(:name, "box1").enabled?)   
       assert_false($ie.checkBox(:name, "box2").enabled?)   

       assert($ie.checkBox(:name, "box4" , 4).enabled?)   
       assert_false($ie.checkBox(:name, "box4" , 5 ).enabled?)   
    end

    def test_checkBox_isSet
       assert_raises(UnknownObjectException ) { $ie.checkBox(:name, "noName").isSet? }  

       assert_false($ie.checkBox(:name, "box1").isSet?)   
       assert_false($ie.checkBox(:name, "box2").isSet?)   
       assert($ie.checkBox(:name, "box3").isSet?)   

       assert_false($ie.checkBox(:name, "box4" , 2 ).isSet?)   
       assert($ie.checkBox(:name, "box4" , 1 ).isSet?)   
    end

    def test_checkBox_clear
       assert_raises(UnknownObjectException) { $ie.checkBox(:name, "noName").clear }  
       $ie.checkBox(:name, "box1").clear
       assert_false($ie.checkBox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { $ie.checkBox(:name, "box2").clear } 
       assert_false($ie.checkBox(:name, "box2").isSet?)   

       $ie.checkBox(:name, "box3").clear
       assert_false($ie.checkBox(:name, "box3").isSet?)   

       $ie.checkBox(:name, "box4" , 1).clear
       assert_false($ie.checkBox(:name, "box4" , 1).isSet?)   
    end

    def test_checkBox_getSTate
       assert_raises(UnknownObjectException) { $ie.checkBox(:name, "noName").getState }  
       assert_equal( false , $ie.checkBox(:name, "box1").getState )   
       assert_equal( true , $ie.checkBox(:name, "box3").getState)   

       # checkboxes that have the same name but different values
       assert_equal( false , $ie.checkBox(:name, "box4" , 2).getState )   
       assert_equal( true , $ie.checkBox(:name, "box4" , 1).getState)   
    end

    def test_checkBox_set
       assert_raises(UnknownObjectException) { $ie.checkBox(:name, "noName").set }  
       $ie.checkBox(:name, "box1").set
       assert($ie.checkBox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { $ie.checkBox(:name, "box2").set }  

       $ie.checkBox(:name, "box3").set
       assert($ie.checkBox(:name, "box3").isSet?)   

       # checkboxes that have the same name but different values
       $ie.checkBox(:name, "box4" , 3).set
       assert($ie.checkBox(:name, "box4" , 3).isSet?)   
    end
end
