# feature tests for Images
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'ftools'
require 'webrick'
require 'watir/cookiemanager'

class TC_Images_XPath < Test::Unit::TestCase
  include Watir
  
  def setup
    gotoImagePage
  end
  
  def gotoImagePage
    goto_page "images1.html"
  end
  
  def test_imageExists
    assert_false( browser.image(:xpath , "//img[@name='missing_name']/").exists?  )
    assert(       browser.image(:xpath , "//img[@name='circle']/").exists?  )
    # assert(       browser.image(:name , /circ/ ).exists?  )
    
    assert_false( browser.image(:xpath , "//img[@id='missing_id']/").exists?  )
    assert(       browser.image(:xpath , "//img[@id='square']/").exists?  )
    # assert(       browser.image(:id , /squ/ ).exists?  )
    
    assert_false( browser.image(:xpath , "//img[@src='missingsrc.gif']/").exists?  )
    
    # BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
    # assert(       browser.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
    # assert(       browser.image(:src , /triangle/ ).exists?  )
    
    assert(       browser.image(:alt , "circle" ).exists?  )
    # assert(       browser.image(:alt , /cir/ ).exists?  )
    
    assert_false(  browser.image(:alt , "triangle" ).exists?  )
    # assert_false(  browser.image(:alt , /tri/ ).exists?  )
  end
  
  def test_image_click
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']/").click }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']/").click }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']/").click}
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@alt='no_image_with_this']/").click}
    
    # test for bug 1882
    browser.text_field(:name , "text1").clear
    browser.button(:value , /Pos/ ).click
    assert_equal('clicked' , browser.text_field(:name , "text1" ).value )
    
    # test for disabled button
    # assert_false( browser.image(:name , 'disabler_test').disabled )
    # browser.button(:name , 'disable_img').click
    
    # assert( browser.image(:name , 'disabler_test').disabled )
    # browser.button(:name , 'disable_img').click
    
    # browser.image(:src, /button/).click
    # assert(browser.text.include?("PASS") )
    
  end
  
  
  
  def test_imageHasLoaded
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@alt='no_image_with_this']/").hasLoaded? }
    
    assert_false( browser.image(:xpath , "//img[@name='themissingimage']/").hasLoaded?  )
    assert( browser.image(:xpath , "//img[@name='circle']/").hasLoaded?  )
    
    assert( browser.image(:xpath , "//img[@alt='circle']/").hasLoaded?  )
    # assert( browser.image(:alt, /cir/ ).hasLoaded?  )
  end
  
  def test_image_properties
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']/").hasLoaded? }
    
    # to string tests -- output should be verified!
    puts browser.image(:xpath , "//img[@name='circle']/").to_s
  end
  
end

