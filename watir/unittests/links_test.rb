# feature tests for Links
# revision: $Revision$

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
    assert_raises(MissingWayOfFindingObjectException) { browser.link(:bad_attribute, 199).click }  
    begin
      browser.link(:bad_attribute, 199).click 
    rescue MissingWayOfFindingObjectException => e           
      assert_equal "bad_attribute is an unknown way of finding a <A> element (199)", e.to_s
    end
  end
  
  def xtest_missing_links_dont_exist
    assert(!exists?{browser.link(:text, "missing")})   
    assert(!exists?{browser.link(:text, /miss/)})   
  end
  
  def test_link_Exists
    assert(browser.link(:text, "test1").exists?)   
    assert(browser.link(:text, /TEST/i).exists?)   
    assert(!browser.link(:text, "missing").exists?)   
    assert(!browser.link(:text, /miss/).exists?)   
    
    # this assert we have to build up the path
    #  this is what it looks like if you do a to_s on the link  file:///C:/watir_bonus/unitTests/html/links1.HTML
    # but what we get back from $htmlRoot is a mixed case, so its almost impossible for use to test this correctly
    # assert(browser.link(:url,'file:///C:/watir_bonus/unitTests/html/links1.HTML' ).exists?)   
    
    assert(browser.link(:url, /link_pass.html/).exists?)   
    assert(!browser.link(:url, "alsomissing.html").exists?)   
    
    assert(browser.link(:id, "link_id").exists?)   
    assert(!browser.link(:id, "alsomissing").exists?)   
    
    assert(browser.link(:id, /_id/).exists?)   
    assert(!browser.link(:id, /alsomissing/).exists?)   
    
    assert(browser.link(:name, "link_name").exists?)   
    assert(!browser.link(:name, "alsomissing").exists?)   
    
    assert(browser.link(:name, /_n/).exists?)   
    assert(!browser.link(:name, /missing/).exists?)   
    
    assert(browser.link(:title, /ti/).exists?)   
    assert(browser.link(:title, "link_title").exists?)   
    
    assert(!browser.link(:title, /missing/).exists?)   
    
    assert(browser.link(:url, /_pass/).exists?)   
    assert(!browser.link(:url, /dont_exist/).exists?)   
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
  
  tag_method :test_link_properties, :fails_on_firefox
  def test_link_properties
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).href }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).value}  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).innerText }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).name }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).id }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).disabled }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).type }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.link(:index, 199).class_name }  
    
    assert_match( /links2/ ,browser.link(:index, 1).href )
    assert_equal( ""      , browser.link(:index, 1).value)
    assert_equal( "test1" , browser.link(:index, 1).innerText )
    assert_equal( ""      , browser.link(:index, 1).name )
    assert_equal( ""      , browser.link(:index, 1).id )
    assert_equal( false   , browser.link(:index, 1).disabled )  
    assert_equal( ""      , browser.link(:index, 1).class_name)
    assert_equal( "link_class_1"      , browser.link(:index, 2).class_name)
    
    assert_equal( "link_id"   , browser.link(:index, 6).id )
    assert_equal( "link_name" , browser.link(:index, 7).name )
    
    assert_equal( "" , browser.link(:index, 7).title)
    
    assert_equal( "link_title" , browser.link(:index, 8).title)
  end
  
  def test_link_iterator
    assert_equal(9, browser.links.length )
    assert_equal("Link Using a name" , browser.links[7].innerText)
    
    index = 1
    browser.links.each do |link|
      assert_equal( browser.link(:index, index).href      , link.href )
      assert_equal( browser.link(:index, index).id        , link.id )
      assert_equal( browser.link(:index, index).name      , link.name )
      assert_equal( browser.link(:index, index).innerText , link.innerText )
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
    assert(browser.frame("linkFrame").link(:text, "test1").exists?)   
    assert(!browser.frame("linkFrame").link(:text, "missing").exists?)   
    
    assert_raises(UnknownObjectException, "UnknownObjectException  was supposed to be thrown" ) { browser.frame("linkFrame").link(:index, 199).href }  
    assert_match(/links2/, browser.frame("linkFrame").link(:index, 1).href)
    
    count =0
    browser.frame("linkFrame").links.each do |l|
      count+=1
    end
    
    assert_equal( 9 , count)
  end    
end

require 'unittests/iostring'
class TC_showlinks < Test::Unit::TestCase
  tags :fails_on_firefox
  include MockStdoutTestCase
  
  def test_showLinks
    goto_page "links1.html"
    $stdout = @mockout
    browser.showLinks
    expected = [/^index name +id +href + text\/src$/,
    get_path_regex(1, "links2.html", "test1"),
    get_path_regex(2, "link_pass.html", "test1"),
    get_path_regex(3, "pass3.html", " / file:///#{$myDir.downcase}/html/images/button.jpg"),
    get_path_regex(4, "textarea.html", "new window"),
    get_path_regex(5, "textarea.html", "new window"),
    get_path_regex(6, "links1.html", "link using an id", "link_id"),
    get_path_regex(7, "links1.html", "link using a name", "link_name"),
    get_path_regex(8, "links1.html", "link using a title"),
    get_path_regex(9, "pass.html", "image and a text link / file:///#{$myDir.downcase}/html/images/triangle.jpg")]
    items = @mockout.split(/\n/).collect {|s| CGI.unescape(s.downcase.strip)}
    expected.each_with_index{|regex, x| assert_match(regex, items[x])}
  end
  
  def get_path_regex(idx, name, inner, nameid="")
    Regexp.new("^#{idx} +#{nameid} +file:///#{$myDir.downcase}/html/#{name} *#{inner}$")
  end
end
