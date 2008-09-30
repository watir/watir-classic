# feature tests for Links
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Links < Test::Unit::TestCase
    
    
    def setup()
        goto_page("links1.html")
    end
    
    def test_new_link_exists
        assert(browser.link(:text, "test1").exists?)   
        assert(browser.link(:text, /TEST/i).exists?)   
    end
    
    # In current implementation, method_missing catches all the methods that are not defined
    # for the element. So there is no way to find out about missinwayoffindingobject exp.
    tag_method :test_bad_attribute, :fails_on_ie
    def test_bad_attribute
        assert_raises(UnknownObjectException) { browser.link(:bad_attribute, 199).click }  
        begin
            browser.link(:bad_attribute, 199).click 
        rescue UnknownObjectException => e           
            assert_equal "Unable to locate object, using bad_attribute and 199", e.to_s
        end
    end

    def test_missing_links_dont_exist
        assert_false(browser.link(:text, "missing").exists?)   
        assert_false(browser.link(:text, /miss/).exists?)   
    end

    def test_link_Exists
        assert(browser.link(:text, "test1").exists?)   
        assert(browser.link(:text, /TEST/i).exists?)   
        assert_false(browser.link(:text, "missing").exists?)   
        assert_false(browser.link(:text, /miss/).exists?)   
        
        # this assert we have to build up the path
        #  this is what it looks like if you do a to_s on the link  file:///C:/watir_bonus/unitTests/html/links1.HTML
        # but what we get back from $htmlRoot is a mixed case, so its almost impossible for use to test this correctly
        # assert(browser.link(:url,'file:///C:/watir_bonus/unitTests/html/links1.HTML' ).exists?)   
        
        assert(browser.link(:url, /link_pass.html/).exists?)   
        assert_false(browser.link(:url, "alsomissing.html").exists?)   
        
        assert(browser.link(:id, "link_id").exists?)   
        assert_false(browser.link(:id, "alsomissing").exists?)   
        
        assert(browser.link(:id, /_id/).exists?)   
        assert_false(browser.link(:id, /alsomissing/).exists?)   
        
        assert(browser.link(:name, "link_name").exists?)   
        assert_false(browser.link(:name, "alsomissing").exists?)   
        
        assert(browser.link(:name, /_n/).exists?)   
        assert_false(browser.link(:name, /missing/).exists?)   
        
        assert(browser.link(:title, /ti/).exists?)   
        assert(browser.link(:title, "link_title").exists?)   
        
        assert_false(browser.link(:title, /missing/).exists?)   
        
        assert(browser.link(:url, /_pass/).exists?)   
        assert_false(browser.link(:url, /dont_exist/).exists?)   
    end
    
    def test_link_click
        browser.link(:text, "test1").click
        assert( browser.text.include?("Links2-Pass") ) 
    end
    def test_link2_click    
        browser.link(:url, /link_pass.html/).click
        assert( browser.text.include?("Links3-Pass") ) 
    end
    def test_link3_click        
        browser.link(:index, 1).click
        assert( browser.text.include?("Links2-Pass") ) 
    end
    def test_link4_click        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).click }  
    end
    
    def test_link_properties
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).href }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).text }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).type }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).class_name }  
        
        assert_match( /links2/ ,browser.link(:index, 1).href )
        assert_equal( ""      , browser.link(:index, 1).value)
        assert_equal( "test1" , browser.link(:index, 1).text )
        assert_equal( ""      , browser.link(:index, 1).name )
        assert_equal( ""      , browser.link(:index, 1).id )
        #assert_equal( false   , browser.link(:index, 1).disabled )  
        assert_equal( ""      , browser.link(:index, 1).class_name)
        assert_equal( "link_class_1"      , browser.link(:index, 2).class_name)
        
        assert_equal( "link_id"   , browser.link(:index, 6).id )
        assert_equal( "link_name" , browser.link(:index, 7).name )
        
        assert_equal( "" , browser.link(:index, 7).title)
        
        assert_equal( "link_title" , browser.link(:index, 8).title)
    end

    def test_text_attribute
        arr1 = browser.link(:text, "nameDelet").to_s
        arr2 = browser.link(:text, /Delet/).to_s
        assert_equal(arr1, arr2)
        
    end
    
    def test_link_iterator
        assert_equal(11, browser.links.length )
        assert_equal("Link Using a name" , browser.links[7].text)
        
        index = 1
        browser.links.each do |link|
            assert_equal( browser.link(:index, index).href      , link.href )
            assert_equal( browser.link(:index, index).id        , link.id )
            assert_equal( browser.link(:index, index).name      , link.name )
            assert_equal( browser.link(:index, index).innerText , link.text )
            index+=1
        end
    end
    
    def test_div_xml_bug
        goto_page("div_xml.html")
        assert_nothing_raised {browser.link(:text, 'Create').exists? }   
    end
    def test_link_to_s
       puts  browser.link(:id,"linktos").to_s
    end
end

class TC_Frame_Links < Test::Unit::TestCase
    
    
    def setup()
        goto_page("frame_links.html")
    end

    def test_new_frame_link_exists
        assert(browser.frame("buttonFrame").link(:text, "test1").exists?)   
    end
    def test_missing_frame_links_dont_exist        
        assert_false(browser.frame("buttonFrame").link(:text, "missing").exists?)
        assert_raise(UnknownFrameException, "UnknownFrameException was supposed to be thrown"){browser.frame("missing").link(:text, "test1").exists?}
    end
    
    def test_links_in_frames
        assert(browser.frame("buttonFrame").link(:text, "test1").exists?)   
        assert_false(browser.frame("buttonFrame").link(:text, "missing").exists?)   
        
        assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) { browser.frame("buttonFrame").link(:index, 199).href }  
        assert_match(/links2/, browser.frame("buttonFrame").link(:index, 1).href)
        
        count =0
        browser.frame("buttonFrame").links.each do |l|
            count+=1
        end
        
        assert_equal(11 , count)
    end    
end

class TC_Links_Display < Test::Unit::TestCase
  
  include MockStdoutTestCase

  tag_method :test_showLinks, :fails_on_ie
  def test_showLinks
    goto_page("links1.html")
    $stdout = @mockout
    browser.showLinks
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
