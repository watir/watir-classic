# feature tests for Forms
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
        
    def test_ButtonInForm
        assert($ie.form(:name ,"test2").button(:caption , "Submit").exists?)
    end     
end

require 'unittests/iostring'
class TC_Form_Display < Test::Unit::TestCase
    include MockStdoutTestCase                
    def test_showforms
        $ie.goto($htmlRoot + "forms2.html")
    @mockout = IOString.new ""
    $stdout = @mockout
        $ie.showForms
        assert_equal(<<END_OF_MESSAGE, @mockout)
There are 4 forms
Form name: 
       id: 
   method: get
   action: pass.html
Form name: test2
       id: 
   method: get
   action: pass2.html
Form name: test3
       id: 
   method: get
   action: pass2.html
Form name: test2
       id: 
   method: get
   action: pass2.html
END_OF_MESSAGE
    end
end

class TC_Forms3 < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "forms3.html")
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

    def test_showforms
       puts"--------------------------- forms----------------------"
        $ie.showForms
    end

    def test_Flash
        $ie.form(:name ,"test2").button(:caption , "Submit").flash
    end 

    def test_objects_with_same_name
        assert_equal('textfield' ,$ie.textField( :name , 'g1').getProperty('value') )
        assert_equal('button'    ,$ie.button(    :name , 'g1').getProperty('value') )
        assert_equal('1'         ,$ie.checkBox(  :name , 'g1').getProperty('value') )
        assert_equal('2'         ,$ie.radio(     :name , 'g1').getProperty('value') )

        assert_equal('textfield_id' ,$ie.textField( :id , 'g1').getProperty('value') )
        assert_equal('button_id'    ,$ie.button(    :id , 'g1').getProperty('value') )
        assert_equal('1_id'         ,$ie.checkBox(  :id , 'g1').getProperty('value') )
        assert_equal('2_id'         ,$ie.radio(     :id , 'g1').getProperty('value') )
    end

    def test_flash
        $ie.button( 'Click Me').flash
        assert_raises( UnknownObjectException ) { $ie.textField( :name , 'g177').flash   }
    end

    def test_showElements
        $ie.showAllObjects
    end

    def test_showText
       puts $ie.getText
    end

    def test_showHTML
       puts $ie.getHTML
    end

    def test_submitWithImage
        assert( $ie.button(:alt , "submit").exists? )
        assert( $ie.button(:alt , /sub/).exists? )

        assert_false( $ie.button(:alt , "missing").exists? )
        assert_false( $ie.button(:alt , /missing/).exists? )

        #assert( $ie.button(:src , "file:///#{$myDir}/html/images/button.jpg").exists? )    # this doesnt work for everybody
        assert( $ie.button(:src , /button/).exists? )

        assert_false( $ie.button(:src , "missing").exists? )
        assert_false( $ie.button(:src , /missing/).exists? )
        assert_nothing_raised("raised an exception when it shouldnt have") { $ie.button(:src , /button/).click }

        assert( $ie.pageContainsText("PASS") )
    end
end

class TC_Forms4 < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "forms4.html")
    end
    
    def test_find_text_field_ignoring_form
        assert_equal($ie.textField(:name, 'name').getContents, 'apple') # should it raise a not-unique error instead?
    end
    
    def test_correct_form_field_is_found_using_form_name
        assert_equal($ie.form(:name, 'apple_form').textField(:name, 'name').getContents, 'apple')
        assert_equal($ie.form(:name, 'banana_form').textField(:name, 'name').getContents, 'banana')
    end

    def test_correct_form_field_is_found_using_form_index
        assert_equal($ie.form(:index, 1).textField(:name, 'name').getContents, 'apple')
        assert_equal($ie.form(:index, 2).textField(:name, 'name').getContents, 'banana')
    end
end