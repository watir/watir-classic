# feature tests for Links
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Links < Test::Unit::TestCase
    include Watir

    def gotoLinksPage()
        $ie.goto($htmlRoot + "links1.html")
    end

    def setup()
        gotoLinksPage()
    end

    
    def test_Link_Exists
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


        $ie.link(:text, "test1").click
        assert( $ie.contains_text("Links2-Pass") ) 

        gotoLinksPage()

        $ie.link(:url, "link_pass.html").click
        assert( $ie.contains_text("Links3-Pass") ) 

        gotoLinksPage()

        $ie.link(:index, 1).click
        assert( $ie.contains_text("Links2-Pass") ) 

        gotoLinksPage()
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).click }  
    end

    def test_link_properties
        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).href }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).innerText }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).type }  


        assert_match( /links2/ ,$ie.link(:index, 1).href )
        assert_equal( ""      , $ie.link(:index, 1).value)
        assert_equal( "test1" , $ie.link(:index, 1).innerText )
        assert_equal( ""      , $ie.link(:index, 1).name )
        assert_equal( ""      , $ie.link(:index, 1).id )
        assert_equal( false   , $ie.link(:index, 1).disabled )  
        assert_equal( "link"  , $ie.link(:index, 1).type )

        assert_equal( "link_id"   , $ie.link(:index, 6).id )
        assert_equal( "link_name" , $ie.link(:index, 7).name )


    end

    def test_showLinks
        $ie.showLinks
    end


    def test_link_iterator

        assert_equal(7, $ie.links.length )
        assert_equal("Link Using a name" , $ie.links[7].innerText)

        index = 1
        $ie.links.each do |link|

            assert_equal( $ie.link(:index, index).href      , link.href )
            assert_equal( $ie.link(:index, index).id        , link.id )
            assert_equal( $ie.link(:index, index).name      , link.name )
            assert_equal( $ie.link(:index, index).innerText , link.innerText )

            index+=1
        end

    end


end

