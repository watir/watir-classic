# tests for Links
# revision: $Revision$

require 'unittests/setup'

class TC_Links < Test::Unit::TestCase


    def gotoLinksPage()
        $ie.goto($htmlRoot + "links1.html")
    end

    

   

    def test_Link_Exists
       gotoLinksPage()
       assert($ie.link(:text, "test1").exists?)   
       assert($ie.link(:text, /TEST/i).exists?)   
       assert_false($ie.link(:text, "missing").exists?)   
       assert_false($ie.link(:text, /miss/).exists?)   

       assert($ie.link(:url, "link_pass.html").exists?)   
       assert_false($ie.link(:url, "alsomissing.html").exists?)   

       assert($ie.link(:id, "link_id").exists?)   
       assert_false($ie.link(:id, "alsomissing").exists?)   

       assert($ie.link(:id, /_id/).exists?)   
       assert_false($ie.link(:id, /alsomissing/).exists?)   

       assert($ie.link(:name, "link_name").exists?)   
       assert_false($ie.link(:name, "alsomissing").exists?)   

       assert($ie.link(:name, /_n/).exists?)   
       assert_false($ie.link(:name, /missing/).exists?)   




    end


    def test_Link_click

       gotoLinksPage()

        $ie.link(:text, "test1").click
        assert( $ie.pageContainsText("Links2-Pass") ) 

       gotoLinksPage()

        $ie.link(:url, "link_pass.html").click
        assert( $ie.pageContainsText("Links3-Pass") ) 

       gotoLinksPage()

        $ie.link(:index, 1).click
        assert( $ie.pageContainsText("Links2-Pass") ) 

       gotoLinksPage()

        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).click }  




    end

    def test_showLinks

        gotoLinksPage()
        $ie.showLinks

    end



end

