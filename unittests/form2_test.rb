# tests for Forms
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'
require 'unittests/setup'

class TC_Forms < Test::Unit::TestCase


    def gotoFormsPage()
        $ie.goto("file://#{$myDir}/html/forms2.html")
    end


    def test_Form_Exists
       gotoFormsPage()

       assert($ie.form(:name, "test2").exists?)   
       assert_false($ie.form(:name, "missing").exists?)   

       assert($ie.form("test2").exists?)   
       assert_false($ie.form( "missing").exists?)   

       assert($ie.form(:index,  1).exists?)   
       assert_false($ie.form(:index, 4).exists?)   

       assert($ie.form(:method, "get").exists?)   
       assert_false($ie.form(:method, "missing").exists?)   

       assert($ie.form(:action, "pass.html").exists?)   
       assert_false($ie.form(:action, "missing").exists?)   



       
    end

    def test_ButtonInForm
       gotoFormsPage()

        assert($ie.form(:name ,"test2").button(:caption , "Submit").exists?)
    end 

end
