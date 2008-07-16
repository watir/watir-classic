# feature tests for Radio Buttons
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Radios < Test::Unit::TestCase
    include FireWatir

    def setup()
        $ff.goto($htmlRoot + "radioButtons1.html")
    end
    
    def test_Radio_Exists
       assert($ff.radio(:name, "box1").exists?)   
       assert($ff.radio(:id, "box5").exists?)   

       assert_false($ff.radio(:name, "missingname").exists?)   
       assert_false($ff.radio(:id, "missingid").exists?)   
    end

    def test_radio_class
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").class_name }  
       assert_equal("radio_style" , $ff.radio(:name, "box1").class_name)   
       assert_equal("" , $ff.radio(:id, "box5").class_name)   
    end

    def test_Radio_Enabled
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:id, "noName").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "box4" , 6).enabled?  }  

       assert_false($ff.radio(:name, "box2").enabled?)   
       assert($ff.radio(:id, "box5").enabled?)   
       assert($ff.radio(:name, "box1").enabled?)   
    end

   def test_little
       assert_false($ff.button(:value , "foo").enabled?)
   end

   def test_onClick

       assert_false($ff.radio(:name, "box5").isSet?)
       assert_false($ff.button(:value , "foo").enabled?)

       # first click the button is enabled and the radio is set
       $ff.radio(:name, "box5" , 1).click
       assert($ff.radio(:name, "box5",1).isSet?)
       #assert($ff.button(:value , "foo").enabled?)

       # second click the button is disabled and the radio is still set
       $ff.radio(:name, "box5", 1).click
       assert($ff.radio(:name, "box5",1).isSet?)
       assert_false($ff.button(:value , "foo").enabled?)

       # third click the button is enabled and the radio is still set
       $ff.radio(:name, "box5", 1).click
       assert($ff.radio(:name, "box5",1 ).isSet?)
       assert($ff.button(:value , "foo").enabled?)

       # click the radio with a value of 2 , button is disabled and the radio is still set
       $ff.radio(:name, "box5", 2).click
       assert_false($ff.radio(:name, "box5" ,1).isSet?)
       assert($ff.radio(:name, "box5" ,2).isSet?)
       assert_false($ff.button(:value , "foo").enabled?)
    end

    def test_Radio_isSet
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").isSet?  }  

       assert_false($ff.radio(:name, "box1").isSet?)   
       assert( $ff.radio(:name, "box3").isSet?)   
       assert_false($ff.radio(:name, "box2").isSet?)   
       assert( $ff.radio(:name, "box4" , 1 ).isSet?)   
       assert_false($ff.radio(:name, "box4" , 2 ).isSet?)   
    end

    def test_radio_clear
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").clear  }  

       $ff.radio(:name, "box1").clear
       assert_false($ff.radio(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ff.radio(:name, "box2").clear  } 
       assert_false($ff.radio(:name, "box2").isSet?)   

       $ff.radio(:name, "box3").clear
       assert_false($ff.radio(:name, "box3").isSet?)   

       $ff.radio(:name, "box4" , 1).clear
       assert_false($ff.radio(:name, "box4" , 1).isSet?)   
    end

    def test_radio_getState
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").getState  }  

       assert_equal( false , $ff.radio(:name, "box1").getState )   
       assert_equal( true , $ff.radio(:name, "box3").getState)   

       # radioes that have the same name but different values
       assert_equal( false , $ff.radio(:name, "box4" , 2).getState )   
       assert_equal( true , $ff.radio(:name, "box4" , 1).getState)   
    end

    def test_radio_set
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.radio(:name, "noName").set  }  
       $ff.radio(:name, "box1").set
       assert($ff.radio(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ff.radio(:name, "box2").set  }  

       $ff.radio(:name, "box3").set
       assert($ff.radio(:name, "box3").isSet?)   

       # radioes that have the same name but different values
       $ff.radio(:name, "box4" , 3).set
       assert($ff.radio(:name, "box4" , 3).isSet?)   
    end

    def test_radio_properties

        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.radio(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.radio(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.radio(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.radio(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.radio(:index, 199).type }  

        assert_equal("on"   ,    $ff.radio(:index, 1).value)  
        assert_equal("box1" ,    $ff.radio(:index, 1).name )  
        assert_equal(""     ,    $ff.radio(:index, 1).id )  
        assert_equal("radio",    $ff.radio(:index, 1).type )  

        assert_equal( false, $ff.radio(:index, 1).disabled )
        assert_equal( true,  $ff.radio(:index, 3).disabled )

        assert_equal("box5"  ,    $ff.radio(:index, 2).id )  
        assert_equal(""      ,    $ff.radio(:index, 2).name )  

        assert_equal("box4-value5", $ff.radio(:name , "box4" , 5 ).title  )
        assert_equal("", $ff.radio(:name , "box4" , 4 ).title  )


    end

    def test_radio_iterators
        
        assert_equal(11, $ff.radios.length)
        assert_equal("box5" , $ff.radios[2].id )
        assert_equal(true ,  $ff.radios[3].disabled )
        assert_equal(false ,  $ff.radios[1].disabled )
        index = 1
        $ff.radios.each do |r|
            assert_equal( $ff.radio(:index, index).name , r.name )
            assert_equal( $ff.radio(:index, index).id , r.id )
            assert_equal( $ff.radio(:index, index).value, r.value)
            assert_equal( $ff.radio(:index, index).disabled , r.disabled )
            assert_equal( $ff.radio(:index, index).isSet? , r.isSet? )
            index+=1
        end
        assert_equal(index -1, $ff.radios.length)
    end


end

