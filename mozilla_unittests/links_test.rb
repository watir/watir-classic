# feature tests for Links
# revision: $Revision: 1.41 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_Links < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "links1.html")
    end
    
    def test_new_link_exists
        assert($ie.link(:text, "test1").exists?)   
        assert($ie.link(:text, /TEST/i).exists?)   
    end
    
    # In current implementation, method_missing catches all the methods that are not defined
    # for the element. So there is no way to find out about missinwayoffindingobject exp.
    def test_bad_attribute
        assert_raises(UnknownObjectException) { $ie.link(:bad_attribute, 199).click }  
        begin
            $ie.link(:bad_attribute, 199).click 
        rescue UnknownObjectException => e           
            assert_equal "Unable to locate object, using bad_attribute and 199", e.to_s
        end
    end

    def test_missing_links_dont_exist
        assert_false($ie.link(:text, "missing").exists?)   
        assert_false($ie.link(:text, /miss/).exists?)   
    end

    def test_link_Exists
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
    
    def test_link_click
        $ie.link(:text, "test1").click
        assert( $ie.text.include?("Links2-Pass") ) 
    end
    def test_link2_click    
        $ie.link(:url, /link_pass.html/).click
        assert( $ie.text.include?("Links3-Pass") ) 
    end
    def test_link3_click        
        $ie.link(:index, 1).click
        assert( $ie.text.include?("Links2-Pass") ) 
    end
    def test_link4_click        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).click }  
    end
    
    def test_link_properties
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).href }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).text }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).type }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.link(:index, 199).class_name }  
        
        assert_match( /links2/ ,$ie.link(:index, 1).href )
        assert_equal( ""      , $ie.link(:index, 1).value)
        assert_equal( "test1" , $ie.link(:index, 1).text )
        assert_equal( ""      , $ie.link(:index, 1).name )
        assert_equal( ""      , $ie.link(:index, 1).id )
        #assert_equal( false   , $ie.link(:index, 1).disabled )  
        assert_equal( ""      , $ie.link(:index, 1).class_name)
        assert_equal( "link_class_1"      , $ie.link(:index, 2).class_name)
        
        assert_equal( "link_id"   , $ie.link(:index, 6).id )
        assert_equal( "link_name" , $ie.link(:index, 7).name )
        
        assert_equal( "" , $ie.link(:index, 7).title)
        
        assert_equal( "link_title" , $ie.link(:index, 8).title)
    end
    
    #def aatest_link_iterator
    #    assert_equal(9, $ie.links.length )
    #    assert_equal("Link Using a name" , $ie.links[7].text)
    #    
    #    index = 1
    #    $ie.links.each do |link|
    #        assert_equal( $ie.link(:index, index).href      , link.href )
    #        assert_equal( $ie.link(:index, index).id        , link.id )
    #        assert_equal( $ie.link(:index, index).name      , link.name )
    #        assert_equal( $ie.link(:index, index).innerText , link.text )
    #        index+=1
    #    end
    #end
    
    def test_div_xml_bug
        $ie.goto($htmlRoot + "div_xml.html")
        assert_nothing_raised {$ie.link(:text, 'Create').exists? }   
    end
end

#class TC_Frame_Links < Test::Unit::TestCase
#    include Watir
    
#    def setup()
#        $ie.goto($htmlRoot + "frame_links.html")
#    end

#    def aatest_new_frame_link_exists
#        assert(exists?{$ie.frame("buttonFrame").link(:text, "test1")})   
#    end
#    def xtest_missing_frame_links_dont_exist        
#        assert_false(exists?{$ie.frame("buttonFrame").link(:text, "missing")})
#        assert_false(exists?{ie.frame("missing").link(:text, "test1")})   
#    end
    
#    def test_links_in_frames
#        assert($ie.frame("buttonFrame").link(:text, "test1").exists?)   
#        assert_false($ie.frame("buttonFrame").link(:text, "missing").exists?)   
        
#       assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) { $ie.frame("buttonFrame").link(:index, 199).href }  
#        assert_match(/links2/, $ie.frame("buttonFrame").link(:index, 1).href)
        
#        count =0
#        $ie.frame("buttonFrame").links.each do |l|
#            count+=1
#        end
#        
#        assert_equal( 9 , count)
#    end    
#end

#require 'unittests/iostring'
#class TC_showlinks < Test::Unit::TestCase
#    include MockStdoutTestCase
    
#    def test_showLinks
#        $ie.goto($htmlRoot + "links1.html")
#        $stdout = @mockout
#       $ie.showLinks
#        expected = [/^index name +id +href + text\/src$/,
#            get_path_regex(1, "links2.html","test1"),
#            get_path_regex(2, "link_pass.html","test1"),
#           get_path_regex(3, "pass3.html", " / file:///#{$myDir.downcase}/html/images/button.jpg"),
#            get_path_regex(4, "textarea.html", "new window"),
#            get_path_regex(5, "textarea.html", "new window"),
#            get_path_regex(6, "links1.html", "link using an id", "link_id"),
#            get_path_regex(7, "links1.html", "link using a name", "link_name"),
#           get_path_regex(8, "links1.html", "link using a title"),
#            get_path_regex(9, "pass.html", "image and a text link / file:///#{$myDir.downcase}/html/images/triangle.jpg")]
#        items = @mockout.split(/\n/).collect {|s|s.downcase.strip}
#        expected.each_with_index{|regex, x| assert_match(regex, items[x])}
#    end
#    
#    def get_path_regex(idx, name, inner, nameid="")
#        Regexp.new("^#{idx} +#{nameid} +file:///#{$myDir.downcase}/html/#{name} *#{inner}$")
#    end
#end
