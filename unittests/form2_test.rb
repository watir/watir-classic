# tests for Forms
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Forms2 < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "forms2.html")
    end
    
    def test_Form_Exists
        assert($ie.form(:name, "test2").exists?)   
        assert_false($ie.form(:name, "missing").exists?)   
        
        assert($ie.form("test2").exists?)   
        assert_false($ie.form( "missing").exists?)   
        
        assert($ie.form(:index,  1).exists?)   
        assert_false($ie.form(:index, 88).exists?)   
        
        assert($ie.form(:method, "get").exists?)   
        assert_false($ie.form(:method, "missing").exists?)   
        
        assert($ie.form(:action, "pass.html").exists?)   
        assert_false($ie.form(:action, "missing").exists?)   
    end
    
    def xtest_showforms
        gotoFormsPage()
        puts"--------------------------- forms----------------------"
        $ie.showForms
    end
    
    def test_ButtonInForm
        assert($ie.form(:name ,"test2").button(:caption , "Submit").exists?)
    end 
    
end
