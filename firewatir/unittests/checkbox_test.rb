# feature tests for Check Boxes
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CheckBox < Test::Unit::TestCase
    

    def setup()
        goto_page("checkboxes1.html")
    end
    
    def test_checkbox_properties
       assert_raises(UnknownObjectException) {   browser.checkbox(:name, "noName").id   }  
       assert_raises(UnknownObjectException) {   browser.checkbox(:name, "noName").name   }  
       assert_raises(UnknownObjectException) {   browser.checkbox(:name, "noName").disabled   }  
       assert_raises(UnknownObjectException) {   browser.checkbox(:name, "noName").type   }  
       assert_raises(UnknownObjectException) {   browser.checkbox(:name, "noName").value   }  

       assert_equal("box1"  , browser.checkbox(:index, 1).name  ) 
       assert_class(browser.checkbox(:index,1), 'Checkbox')
       
       assert_equal(""  , browser.checkbox(:index, 1).id  ) 
       assert_equal("checkbox"  , browser.checkbox(:index, 1).type  ) 
       assert_equal("on"  , browser.checkbox(:index, 1).value  ) 
       assert_equal(false  , browser.checkbox(:index, 1).disabled  ) 

       assert_equal("check_box_style" , browser.checkbox(:name, "box1").class_name) 
       assert_equal("" , browser.checkbox(:name, "box2").class_name) 

       assert_equal("1" , browser.checkbox(:name,"box4").value )
       assert_equal("3" , browser.checkbox(:name,"box4" , 3).value )
       assert_equal("checkbox" , browser.checkbox(:name,"box4" , 3).type )
       assert_equal(false , browser.checkbox(:name,"box4" , 3).disabled )
       assert_equal("" , browser.checkbox(:name,"box4" , 3).id )

       assert_equal("box4-value5" , browser.checkbox(:name,"box4" , 5).title)
       assert_equal("" , browser.checkbox(:name,"box4" , 4).title)
    end

    def test_onClick
       assert_false(browser.button(:value , "foo").enabled?)
       browser.checkbox(:name, "box5").set
       assert(browser.button(:value , "foo").enabled?)

       browser.checkbox(:name, "box5").clear
       assert_false(browser.button(:value , "foo").enabled?)

       browser.checkbox(:name, "box5").clear
       assert_false(browser.button(:value , "foo").enabled?)
    end

    def test_CheckBox_Exists
       assert(browser.checkbox(:name, "box1").exists?)   
       assert_false(browser.checkbox(:name, "missing").exists?)   
    
       assert(browser.checkbox(:name, "box4" , 1).exists?)   
       assert_false(browser.checkbox(:name, "box4" , 22).exists?)   
    end

    #def test_checkbox_Enabled
    #  assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").enabled? }  
    #   assert_raises(UnknownObjectException) { browser.checkbox(:id, "noName").enabled? }  
    #  assert_raises(UnknownObjectException) { browser.checkbox(:name, "box4" , 6).enabled? }  
    #
    #   assert(browser.checkbox(:name, "box1").enabled?)   
    #    assert_false(browser.checkbox(:name, "box2").enabled?)   
    #
    #   assert(browser.checkbox(:name, "box4", 4).enabled?)   
    #  assert_false(browser.checkbox(:name, "box4" , 5 ).enabled?)   
    #end

    def test_checkbox_isSet
       assert_raises(UnknownObjectException ) { browser.checkbox(:name, "noName").isSet? }  

       assert_false(browser.checkbox(:name, "box1").isSet?)   
       assert_false(browser.checkbox(:name, "box2").isSet?)   
       assert(browser.checkbox(:name, "box3").isSet?)   

       assert_false(browser.checkbox(:name, "box4" , 2 ).isSet?)   
       assert(browser.checkbox(:name, "box4" , 1 ).isSet?)   
    end

    def test_checkbox_clear
       assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").clear }  
       browser.checkbox(:name, "box1").clear
       assert_false(browser.checkbox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { browser.checkbox(:name, "box2").clear } 
       assert_false(browser.checkbox(:name, "box2").isSet?)   

       browser.checkbox(:name, "box3").clear
       assert_false(browser.checkbox(:name, "box3").isSet?)   

       browser.checkbox(:name, "box4" , 1).clear
       assert_false(browser.checkbox(:name, "box4" , 1).isSet?)   
    end

    def test_checkbox_getState
       assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").getState }  
       assert_equal( false , browser.checkbox(:name, "box1").getState )   
       assert_equal( true , browser.checkbox(:name, "box3").getState)   

       # checkboxes that have the same name but different values
       assert_equal( false , browser.checkbox(:name, "box4" , 2).getState )   
       assert_equal( true , browser.checkbox(:name, "box4" , 1).getState)   
    end

    def test_checkbox_set
       assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").set }  
       browser.checkbox(:name, "box1").set
       assert(browser.checkbox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { browser.checkbox(:name, "box2").set }  

       browser.checkbox(:name, "box3").set
       assert(browser.checkbox(:name, "box3").isSet?)   

       # checkboxes that have the same name but different values
       browser.checkbox(:name, "box4" , 3).set
       assert(browser.checkbox(:name, "box4" , 3).isSet?)   

       # test set using the optinal true/false
       # assumes the checkbox is already checked
       browser.checkbox(:name, "box1").set( false )
       assert_false(browser.checkbox(:name, "box1").isSet?)   

       browser.checkbox(:name, "box1").set( true )
       assert(browser.checkbox(:name, "box1").isSet?)   




    end

    def test_checkbox_iterator

        assert_equal(11, browser.checkboxes.length)
        assert_equal("box1" , browser.checkboxes[1].name )

        index=1
        browser.checkboxes.each do |c|
            assert_equal( browser.checkbox(:index, index).name , c.name )
            assert_equal( browser.checkbox(:index, index).id, c.id )
            assert_equal( browser.checkbox(:index, index).value, c.value )
            assert_equal( browser.checkbox(:index, index).isSet?, c.isSet? )
            index+=1
        end
        assert_equal(index-1, browser.checkboxes.length)
 
    end


end
