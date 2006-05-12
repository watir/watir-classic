# feature tests for Images
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
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
    $ie.goto($htmlRoot + "images1.html")
  end
  
  def test_imageExists
    assert(! $ie.image(:xpath , "//img[@name='missing_name']/").exists?  )
    assert(       $ie.image(:xpath , "//img[@name='circle']/").exists?  )
    # assert(       $ie.image(:name , /circ/ ).exists?  )
    
    assert(! $ie.image(:xpath , "//img[@id='missing_id']/").exists?  )
    assert(       $ie.image(:xpath , "//img[@id='square']/").exists?  )
    # assert(       $ie.image(:id , /squ/ ).exists?  )
    
    assert(! $ie.image(:xpath , "//img[@src='missingsrc.gif']/").exists?  )
    
    # BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
    # assert(       $ie.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
    # assert(       $ie.image(:src , /triangle/ ).exists?  )
    
    assert(       $ie.image(:alt , "circle" ).exists?  )
    # assert(       $ie.image(:alt , /cir/ ).exists?  )
    
    assert(!  $ie.image(:alt , "triangle" ).exists?  )
    # assert(!  $ie.image(:alt , /tri/ ).exists?  )
  end
  
  def test_image_click
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']/").click }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']/").click }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']/").click}
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@alt='no_image_with_this']/").click}
    
    # test for bug 1882
    $ie.text_field(:name , "text1").clear
    $ie.button(:value , /Pos/ ).click
    assert_equal('clicked' , $ie.text_field(:name , "text1" ).value )
    
    # test for disabled button
    # assert(! $ie.image(:name , 'disabler_test').disabled )
    # $ie.button(:name , 'disable_img').click
    
    # assert( $ie.image(:name , 'disabler_test').disabled )
    # $ie.button(:name , 'disable_img').click
    
    # $ie.image(:src, /button/).click
    # assert($ie.text.include?("PASS") )
    
  end
  
  
  
  def test_imageHasLoaded
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@alt='no_image_with_this']/").hasLoaded? }
    
    assert(! $ie.image(:xpath , "//img[@name='themissingimage']/").hasLoaded?  )
    assert( $ie.image(:xpath , "//img[@name='circle']/").hasLoaded?  )
    
    assert( $ie.image(:xpath , "//img[@alt='circle']/").hasLoaded?  )
    # assert( $ie.image(:alt, /cir/ ).hasLoaded?  )
  end
  
  def test_image_properties
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']/").hasLoaded? }
    assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']/").hasLoaded? }
    
    # to string tests -- output should be verified!
    puts $ie.image(:xpath , "//img[@name='circle']/").to_s
  end
  
end

