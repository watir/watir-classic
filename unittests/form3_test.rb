# tests for Forms
# revision: $Revision$

require 'setup'

class TC_Forms < Test::Unit::TestCase


    def gotoFormsPage()
        $ie.goto($htmlRoot + "forms3.html")
    end


    def test_Form_Exists
       gotoFormsPage()

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
       gotoFormsPage()
       puts"--------------------------- forms----------------------"
        $ie.showForms
    end

    def test_Flash
       gotoFormsPage()

        $ie.form(:name ,"test2").button(:caption , "Submit").flash
    end 

    def test_objects_with_same_name
        gotoFormsPage()
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
