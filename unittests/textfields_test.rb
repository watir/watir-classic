
# tests for Buttons
# revision: $Revision$

require '../watir'

require 'test/unit'
require 'test/unit/ui/console/testrunner'

require 'testUnitAddons'
$myDir = File.dirname(__FILE__)

$LOAD_PATH << $myDir




class TC_Fields < Test::Unit::TestCase


    def gotoPage()
        $ie.goto("file://#{$myDir}/html/textfields1.html")
    end

    

   

    def test_textField_Exists
       gotoPage()
       assert($ie.textField(:name, "text1").exists?)   
       assert_false($ie.textField(:name, "missing").exists?)   

       assert($ie.textField(:id, "text2").exists?)   
       assert_false($ie.textField(:id, "alsomissing").exists?)   

    end

    def test_textField_VerifyContents
       gotoPage()
       assert($ie.textField(:name, "text1").verify_contains("Hello World") )  
       assert($ie.textField(:name, "text1").verify_contains(/Hello\sW/ ) )  
       assert_false($ie.textField(:name, "text1").verify_contains("Ruby") )  
       assert_false($ie.textField(:name, "text1").verify_contains(/R/) )  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.textField(:name, "NoName").verify_contains("No field to get a value of") }  

       assert($ie.textField(:id, "text2").verify_contains("goodbye all") )  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.textField(:id, "noID").verify_contains("No field to get a value of") }  

       



    end

    def test_textField_enabled
       gotoPage()
       assert_false($ie.textField(:name, "disabled").enabled? )  
       assert($ie.textField(:name, "text1").enabled? )  
       assert($ie.textField(:id, "text2").enabled? )  

    end

    def test_textField_readOnly
       gotoPage()
       assert_false($ie.textField(:name, "disabled").readOnly? )  
       assert($ie.textField(:name, "readOnly").readOnly? )  
       assert($ie.textField(:id, "readOnly2").readOnly? )  

    end


    def test_textField_getContents()
         gotoPage()
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  
         assert_equal(  "Hello World" , $ie.textField(:name, "text1").getContents )  


    end


    def test_textField_Append
         gotoPage()
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "text1").append(" Some Text")
         assert_equal(  "Hello World Some Text" , $ie.textField(:name, "text1").getContents )  

         # may need this to see that it really happened
         #puts "press return to continue"
         #gets 

    end


    def test_textField_Clear
         gotoPage()
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "text1").clear()
         assert_equal(  "" , $ie.textField(:name, "text1").getContents )  

         # may need this to see that it really happened
         puts "press return to continue"
         gets 

    end

    def test_textField_Set
         gotoPage()
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "text1").set("watir IE Controleer")
         assert_equal(  "watir IE Controleer" , $ie.textField(:name, "text1").getContents )  

         # may need this to see that it really happened
         puts "press return to continue"
         gets 

    end





end

$ie = IE.new