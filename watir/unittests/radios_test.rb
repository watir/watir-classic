# tests for Radio Buttons
# revision: $Revision$

require 'setup'

class TC_Radios < Test::Unit::TestCase


    def gotoRadioPage()
        $ie.goto($htmlRoot + "radioButtons1.html")
    end

   
    def test_Radio_Exists
       gotoRadioPage()
       assert($ie.radio(:name, "box1").exists?)   
       assert($ie.radio(:id, "box5").exists?)   

       assert_false($ie.radio(:name, "missingname").exists?)   
       assert_false($ie.radio(:id, "missingid").exists?)   
    end

    def test_Radio_Enabled
       gotoRadioPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "noName").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:id, "noName").enabled?  }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "box4" , 6).enabled?  }  



       assert_false($ie.radio(:name, "box2").enabled?)   
       assert($ie.radio(:id, "box5").enabled?)   
       assert($ie.radio(:name, "box1").enabled?)   


    end

    def test_Radio_isSet

       gotoRadioPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "noName").isSet?  }  

       puts "radio 1 is set : #{ $ie.radio(:name, 'box1').isSet? } "
       assert_false($ie.radio(:name, "box1").isSet?)   


       assert( $ie.radio(:name, "box3").isSet?)   
       assert_false($ie.radio(:name, "box2").isSet?)   


       assert( $ie.radio(:name, "box4" , 1 ).isSet?)   
       assert_false($ie.radio(:name, "box4" , 2 ).isSet?)   

    end

    def test_radio_clear

       gotoRadioPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "noName").clear  }  


       $ie.radio(:name, "box1").clear
       assert_false($ie.radio(:name, "box1").isSet?)   


       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ie.radio(:name, "box2").clear  } 
       assert_false($ie.radio(:name, "box2").isSet?)   

       $ie.radio(:name, "box3").clear
       assert_false($ie.radio(:name, "box3").isSet?)   


       $ie.radio(:name, "box4" , 1).clear
       assert_false($ie.radio(:name, "box4" , 1).isSet?)   


    end

    def test_radio_getSTate

       gotoRadioPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "noName").getState  }  

       assert_equal( RadioButton::UNCHECKED , $ie.radio(:name, "box1").getState )   
       assert_equal( RadioButton::CHECKED , $ie.radio(:name, "box3").getState)   

       # radioes that have the sme name but different values

       assert_equal( RadioButton::UNCHECKED , $ie.radio(:name, "box4" , 2).getState )   
       assert_equal( RadioButton::CHECKED , $ie.radio(:name, "box4" , 1).getState)   


    end

    def test_radio_set

       gotoRadioPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.radio(:name, "noName").set  }  

       $ie.radio(:name, "box1").set
       assert($ie.radio(:name, "box1").isSet?)   

       assert_raises(ObjectDisabledException, "ObjectDisabledException was supposed to be thrown" ) {   $ie.radio(:name, "box2").set  }  

       $ie.radio(:name, "box3").set
       assert($ie.radio(:name, "box3").isSet?)   

       # radioes that have the sme name but different values
       $ie.radio(:name, "box4" , 3).set
       assert($ie.radio(:name, "box4" , 3).isSet?)   

    end

end

