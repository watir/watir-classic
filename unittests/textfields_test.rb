
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

       assert_false($ie.textField(:name, "disabled").enabled? )  
       assert($ie.textField(:name, "text1").enabled? )  
       assert($ie.textField(:id, "text2").enabled? )  


    end



end

$ie = IE.new