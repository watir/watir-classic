# feature tests for Check Boxes
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_CheckBox < Test::Unit::TestCase
    include FireWatir

    def setup()
        $ff.goto($htmlRoot + "checkboxes1.html")
    end
    
    def test_checkbox_properties
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.checkbox(:name, "noName").id   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.checkbox(:name, "noName").name   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.checkbox(:name, "noName").disabled   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.checkbox(:name, "noName").type   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.checkbox(:name, "noName").value   }  

       assert_equal("box1"  , $ff.checkbox(:index, 1).name  ) 
       assert_instance_of(CheckBox,$ff.checkbox(:index,1))
       assert_equal(""  , $ff.checkbox(:index, 1).id  ) 
       assert_equal("checkbox"  , $ff.checkbox(:index, 1).type  ) 
       assert_equal("on"  , $ff.checkbox(:index, 1).value  ) 
       assert_equal(false  , $ff.checkbox(:index, 1).disabled  ) 

       assert_equal("check_box_style" , $ff.checkbox(:name, "box1").class_name) 
       assert_equal("" , $ff.checkbox(:name, "box2").class_name) 

       assert_equal("1" , $ff.checkbox(:name,"box4").value )
       assert_equal("3" , $ff.checkbox(:name,"box4" , 3).value )
       assert_equal("checkbox" , $ff.checkbox(:name,"box4" , 3).type )
       assert_equal(false , $ff.checkbox(:name,"box4" , 3).disabled )
       assert_equal("" , $ff.checkbox(:name,"box4" , 3).id )

       assert_equal("box4-value5" , $ff.checkbox(:name,"box4" , 5).title)
       assert_equal("" , $ff.checkbox(:name,"box4" , 4).title)
    end

    def test_onClick
       assert_false($ff.button(:value , "foo").enabled?)
       $ff.checkbox(:name, "box5").set
       assert($ff.button(:value , "foo").enabled?)

       $ff.checkbox(:name, "box5").clear
       assert_false($ff.button(:value , "foo").enabled?)

       $ff.checkbox(:name, "box5").clear
       assert_false($ff.button(:value , "foo").enabled?)
    end

    def test_CheckBox_Exists
       assert($ff.checkbox(:name, "box1").exists?)   
       assert_false($ff.checkbox(:name, "missing").exists?)   
    
       assert($ff.checkbox(:name, "box4" , 1).exists?)   
       assert_false($ff.checkbox(:name, "box4" , 22).exists?)   
    end

    #def test_checkbox_Enabled
    #  assert_raises(UnknownObjectException) { $ff.checkbox(:name, "noName").enabled? }  
    #   assert_raises(UnknownObjectException) { $ff.checkbox(:id, "noName").enabled? }  
    #  assert_raises(UnknownObjectException) { $ff.checkbox(:name, "box4" , 6).enabled? }  
    #
    #   assert($ff.checkbox(:name, "box1").enabled?)   
    #    assert_false($ff.checkbox(:name, "box2").enabled?)   
    #
    #   assert($ff.checkbox(:name, "box4", 4).enabled?)   
    #  assert_false($ff.checkbox(:name, "box4" , 5 ).enabled?)   
    #end

    def test_checkbox_isSet
       assert_raises(UnknownObjectException ) { $ff.checkbox(:name, "noName").isSet? }  

       assert_false($ff.checkbox(:name, "box1").isSet?)   
       assert_false($ff.checkbox(:name, "box2").isSet?)   
       assert($ff.checkbox(:name, "box3").isSet?)   

       assert_false($ff.checkbox(:name, "box4" , 2 ).isSet?)   
       assert($ff.checkbox(:name, "box4" , 1 ).isSet?)   
    end

    def test_checkbox_clear
       assert_raises(UnknownObjectException) { $ff.checkbox(:name, "noName").clear }  
       $ff.checkbox(:name, "box1").clear
       assert_false($ff.checkbox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { $ff.checkbox(:name, "box2").clear } 
       assert_false($ff.checkbox(:name, "box2").isSet?)   

       $ff.checkbox(:name, "box3").clear
       assert_false($ff.checkbox(:name, "box3").isSet?)   

       $ff.checkbox(:name, "box4" , 1).clear
       assert_false($ff.checkbox(:name, "box4" , 1).isSet?)   
    end

    def test_checkbox_getState
       assert_raises(UnknownObjectException) { $ff.checkbox(:name, "noName").getState }  
       assert_equal( false , $ff.checkbox(:name, "box1").getState )   
       assert_equal( true , $ff.checkbox(:name, "box3").getState)   

       # checkboxes that have the same name but different values
       assert_equal( false , $ff.checkbox(:name, "box4" , 2).getState )   
       assert_equal( true , $ff.checkbox(:name, "box4" , 1).getState)   
    end

    def test_checkbox_set
       assert_raises(UnknownObjectException) { $ff.checkbox(:name, "noName").set }  
       $ff.checkbox(:name, "box1").set
       assert($ff.checkbox(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException) { $ff.checkbox(:name, "box2").set }  

       $ff.checkbox(:name, "box3").set
       assert($ff.checkbox(:name, "box3").isSet?)   

       # checkboxes that have the same name but different values
       $ff.checkbox(:name, "box4" , 3).set
       assert($ff.checkbox(:name, "box4" , 3).isSet?)   

       # test set using the optinal true/false
       # assumes the checkbox is already checked
       $ff.checkbox(:name, "box1").set( false )
       assert_false($ff.checkbox(:name, "box1").isSet?)   

       $ff.checkbox(:name, "box1").set( true )
       assert($ff.checkbox(:name, "box1").isSet?)   




    end

    def test_checkbox_iterator

        assert_equal(11, $ff.checkboxes.length)
        assert_equal("box1" , $ff.checkboxes[1].name )

        index=1
        $ff.checkboxes.each do |c|
            assert_equal( $ff.checkbox(:index, index).name , c.name )
            assert_equal( $ff.checkbox(:index, index).id, c.id )
            assert_equal( $ff.checkbox(:index, index).value, c.value )
            assert_equal( $ff.checkbox(:index, index).isSet?, c.isSet? )
            index+=1
        end
        assert_equal(index-1, $ff.checkboxes.length)
 
    end


end
