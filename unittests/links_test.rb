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


       # this assert we have to build up the path
       #  this is what it looks like if you do a to_s on the link  file:///C:/watir_bonus/unitTests/html/links1.HTML
       # but what we get back from $htmlRoot is a mixed case, so its almost impossible for use to test this correctly
       # assert($ie.link(:url,'file:///C:/watir_bonus/unitTests/html/links1.HTML' ).exists?)   


       assert($ie.link(:url, /link_pass.html/).exists?)   
       assert_false($ie.link(:url, "alsomissing.html").exists?)   

       assert($ie.link(:id, "link_id").exists?)   
       assert_false($ie.link(:id, "alsomissing").exists?)   

       assert($ie.link(:id, /_id/).exists?)   
       assert_false($ie.link(:id, /alsomissing/).exists?)   

       assert($ie.link(:name, "link_name").exists?)   
       assert_false($ie.link(:name, "alsomissing").exists?)   

       assert($ie.link(:name, /_n/).exists?)   
       assert_false($ie.link(:name, /missing/).exists?)   

       assert($ie.link(:title, /ti/).exists?)   
       assert($ie.link(:title, "link_title").exists?)   

       assert_false($ie.link(:title, /missing/).exists?)   

       assert($ie.link(:url, /_pass/).exists?)   
       assert_false($ie.link(:url, /dont_exist/).exists?)   



    end


    def test_Link_click


        $ie.link(:text, "test1").click
        assert( $ie.contains_text("Links2-Pass") ) 

        gotoLinksPage()
        $ie.link(:url, /link_pass.html/).click
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

        assert_equal( "" , $ie.link(:index, 7).title)


        assert_equal( "link_title" , $ie.link(:index, 8).title)


    end

    def test_showLinks
        tmp = ""
        def tmp.puts(s) self << s; end
        $ie.showLinks(tmp)
        expected = [/^index name +id +href + text\/src$/,
                    get_path_regex(1, "links2.htmltest1"),
                    get_path_regex(2, "link_pass.htmltest1"),
                    get_path_regex(3, "pass3.html / file:///#{$myDir.downcase}/html/images/button.jpg"),
                    get_path_regex(4, "textarea.htmlnew window"),
                    get_path_regex(5, "textarea.htmlnew window"),
                    get_path_regex(6, "links1.htmllink using an id", "link_id"),
                    get_path_regex(7, "links1.htmllink using a name", "link_name"),
                    get_path_regex(8, "links1.htmllink using a title"),
                    get_path_regex(9, "pass.htmlimage and a text link / file:///#{$myDir.downcase}/html/images/triangle.jpg")]
        items = tmp.split(/\n/).collect {|s|s.downcase.strip}
        expected.each_with_index{|regex, x| assert(regex =~ items[x])}
    end

    def get_path_regex(idx, name, nameid="")
      Regexp.new("^#{idx} +#{nameid} +file:///#{$myDir.downcase}/html/#{name}$")
    end


    def test_link_iterator

        assert_equal(9, $ie.links.length )
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

