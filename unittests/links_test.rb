# feature tests for Links
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Links < Test::Unit::TestCase
    include FireWatir
    
    def setup()
        $ff.goto($htmlRoot + "links1.html")
    end
    
    def test_new_link_exists
        assert($ff.link(:text, "test1").exists?)   
        assert($ff.link(:text, /TEST/i).exists?)   
    end
    
    # In current implementation, method_missing catches all the methods that are not defined
    # for the element. So there is no way to find out about missinwayoffindingobject exp.
    def test_bad_attribute
        assert_raises(UnknownObjectException) { $ff.link(:bad_attribute, 199).click }  
        begin
            $ff.link(:bad_attribute, 199).click 
        rescue UnknownObjectException => e           
            assert_equal "Unable to locate object, using bad_attribute and 199", e.to_s
        end
    end

    def test_missing_links_dont_exist
        assert_false($ff.link(:text, "missing").exists?)   
        assert_false($ff.link(:text, /miss/).exists?)   
    end

    def test_link_Exists
        assert($ff.link(:text, "test1").exists?)   
        assert($ff.link(:text, /TEST/i).exists?)   
        assert_false($ff.link(:text, "missing").exists?)   
        assert_false($ff.link(:text, /miss/).exists?)   
        
        # this assert we have to build up the path
        #  this is what it looks like if you do a to_s on the link  file:///C:/watir_bonus/unitTests/html/links1.HTML
        # but what we get back from $htmlRoot is a mixed case, so its almost impossible for use to test this correctly
        # assert($ff.link(:url,'file:///C:/watir_bonus/unitTests/html/links1.HTML' ).exists?)   
        
        assert($ff.link(:url, /link_pass.html/).exists?)   
        assert_false($ff.link(:url, "alsomissing.html").exists?)   
        
        assert($ff.link(:id, "link_id").exists?)   
        assert_false($ff.link(:id, "alsomissing").exists?)   
        
        assert($ff.link(:id, /_id/).exists?)   
        assert_false($ff.link(:id, /alsomissing/).exists?)   
        
        assert($ff.link(:name, "link_name").exists?)   
        assert_false($ff.link(:name, "alsomissing").exists?)   
        
        assert($ff.link(:name, /_n/).exists?)   
        assert_false($ff.link(:name, /missing/).exists?)   
        
        assert($ff.link(:title, /ti/).exists?)   
        assert($ff.link(:title, "link_title").exists?)   
        
        assert_false($ff.link(:title, /missing/).exists?)   
        
        assert($ff.link(:url, /_pass/).exists?)   
        assert_false($ff.link(:url, /dont_exist/).exists?)   
    end
    
    def test_link_click
        $ff.link(:text, "test1").click
        assert( $ff.text.include?("Links2-Pass") ) 
    end
    def test_link2_click    
        $ff.link(:url, /link_pass.html/).click
        assert( $ff.text.include?("Links3-Pass") ) 
    end
    def test_link3_click        
        $ff.link(:index, 1).click
        assert( $ff.text.include?("Links2-Pass") ) 
    end
    def test_link4_click        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).click }  
    end
    
    def test_link_properties
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).href }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).text }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).type }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ff.link(:index, 199).class_name }  
        
        assert_match( /links2/ ,$ff.link(:index, 1).href )
        assert_equal( ""      , $ff.link(:index, 1).value)
        assert_equal( "test1" , $ff.link(:index, 1).text )
        assert_equal( ""      , $ff.link(:index, 1).name )
        assert_equal( ""      , $ff.link(:index, 1).id )
        #assert_equal( false   , $ff.link(:index, 1).disabled )  
        assert_equal( ""      , $ff.link(:index, 1).class_name)
        assert_equal( "link_class_1"      , $ff.link(:index, 2).class_name)
        
        assert_equal( "link_id"   , $ff.link(:index, 6).id )
        assert_equal( "link_name" , $ff.link(:index, 7).name )
        
        assert_equal( "" , $ff.link(:index, 7).title)
        
        assert_equal( "link_title" , $ff.link(:index, 8).title)
    end

    def test_text_attribute
        arr1 = $ff.link(:text, "nameDelet").to_s
        arr2 = $ff.link(:text, /Delet/).to_s
        assert_equal(arr1, arr2)
        
    end
    
    def test_link_iterator
        assert_equal(11, $ff.links.length )
        assert_equal("Link Using a name" , $ff.links[7].text)
        
        index = 1
        $ff.links.each do |link|
            assert_equal( $ff.link(:index, index).href      , link.href )
            assert_equal( $ff.link(:index, index).id        , link.id )
            assert_equal( $ff.link(:index, index).name      , link.name )
            assert_equal( $ff.link(:index, index).innerText , link.text )
            index+=1
        end
    end
    
    def test_div_xml_bug
        $ff.goto($htmlRoot + "div_xml.html")
        assert_nothing_raised {$ff.link(:text, 'Create').exists? }   
    end
    def test_link_to_s
       puts  $ff.link(:id,"linktos").to_s
    end
end

class TC_Frame_Links < Test::Unit::TestCase
    include FireWatir
    
    def setup()
        $ff.goto($htmlRoot + "frame_links.html")
    end

    def test_new_frame_link_exists
        assert($ff.frame("buttonFrame").link(:text, "test1").exists?)   
    end
    def test_missing_frame_links_dont_exist        
        assert_false($ff.frame("buttonFrame").link(:text, "missing").exists?)
        assert_raise(UnknownFrameException, "UnknownFrameException was supposed to be thrown"){$ff.frame("missing").link(:text, "test1").exists?}
    end
    
    def test_links_in_frames
        assert($ff.frame("buttonFrame").link(:text, "test1").exists?)   
        assert_false($ff.frame("buttonFrame").link(:text, "missing").exists?)   
        
        assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) { $ff.frame("buttonFrame").link(:index, 199).href }  
        assert_match(/links2/, $ff.frame("buttonFrame").link(:index, 1).href)
        
        count =0
        $ff.frame("buttonFrame").links.each do |l|
            count+=1
        end
        
        assert_equal(11 , count)
    end    
end

class TC_Links_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showLinks
    $ff.goto($htmlRoot + "links1.html")
    $stdout = @mockout
    $ff.showLinks
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 11 links
link:  name: 
         id: 
       href: links2.html
      index: 1
link:  name: 
         id: 
       href: link_pass.html
      index: 2
link:  name: 
         id: 
       href: pass3.html
      index: 3
link:  name: 
         id: 
       href: textarea.html
      index: 4
link:  name: 
         id: 
       href: textarea.html
      index: 5
link:  name: 
         id: link_id
       href: links1.HTML
      index: 6
link:  name: link_name
         id: 
       href: links1.HTML
      index: 7
link:  name: 
         id: 
       href: links1.HTML
      index: 8
link:  name: 
         id: 
       href: pass.html
      index: 9
link:  name: 
         id: linktos
       href: link_pass.html
      index: 10
link:  name: test_link
         id: 
       href: link1.html
      index: 11
END_OF_MESSAGE
  end
end
