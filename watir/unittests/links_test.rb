# feature tests for Links

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'cgi'

class TC_Links < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "links1.html"
  end
  
  tag_method :test_bad_attribute, :fails_on_firefox
  def test_bad_attribute
    browser.link(:bad_attribute, 199).click 
    fail "#click should have raised an Exception!"
  rescue MissingWayOfFindingObjectException => e           
    assert_equal "bad_attribute is an unknown way of finding a <a> element (199)", e.to_s
  end
  
  def xtest_missing_links_dont_exist
    assert_false(exists?{browser.link(:text, "missing")})   
    assert_false(exists?{browser.link(:text, /miss/)})   
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
    browser.link(:index, 0).click
    assert( browser.text.include?("Links2-Pass") ) 
  end
  def test_link4_click        
    assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).click }  
  end
  
  def test_link_properties
    assert_raises(UnknownObjectException) { browser.link(:index, 199).href }  
    assert_raises(UnknownObjectException) { browser.link(:index, 199).text }  
    assert_raises(UnknownObjectException) { browser.link(:index, 199).id }  
    assert_raises(UnknownObjectException) { browser.link(:index, 199).class_name }  
    
    assert_match(/links2/ ,browser.link(:index, 0).href )
    assert_equal("test1" , browser.link(:index, 0).text )
    assert_equal(""      , browser.link(:index, 0).id )
    assert_equal(""      , browser.link(:index, 0).class_name)
    assert_equal("link_class_1"      , browser.link(:index, 1).class_name)
    
    assert_equal("link_id"   , browser.link(:index, 5).id )
    
    assert_equal("" , browser.link(:index, 6).title)
    
    assert_equal("link_title" , browser.link(:index, 7).title)
  end
  
  def test_link_iterator
    assert_equal(9, browser.links.length )
    assert_equal("Link Using a name" , browser.links[6].text)
    
    index = 0
    browser.links.each do |link|
      assert_equal(browser.link(:index, index).href      , link.href )
      assert_equal(browser.link(:index, index).id        , link.id )
      assert_equal(browser.link(:index, index).text , link.text )
      index+=1
    end
  end
  
  def test_div_xml_bug
    goto_page "div_xml.html"
    assert_nothing_raised {browser.link(:text, 'Create').exists? }   
  end
end

class TC_Frame_Links < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "frame_links.html"
  end
  
  def test_links_in_frames
    assert(browser.frame(:name => "linkFrame").link(:text, "test1").exists?)   
    assert_false(browser.frame(:name => "linkFrame").link(:text, "missing").exists?)   
    
    assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) { browser.frame(:name => "linkFrame").link(:index, 199).href }  
    assert_match(/links2/, browser.frame(:name => "linkFrame").link(:index, 0).href)
    
    count =0
    browser.frame(:name => "linkFrame").links.each do |l|
      count+=1
    end
    
    assert_equal( 9 , count)
  end    
end
