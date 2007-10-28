# feature tests for Images
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'ftools'
require 'webrick'

class TC_Images_XPath < Test::Unit::TestCase
    include FireWatir
    
    def setup
        gotoImagePage
    end
    
    def gotoImagePage()
        $ff.goto($htmlRoot + "images1.html")
    end

    def test_imageExists
        assert_false( $ff.image(:xpath , "//img[@name='missing_name']").exists?  )
        assert(       $ff.image(:xpath , "//img[@name='circle']").exists?  )
        assert(       $ff.image(:xpath , "//img[contains(@name , 'circ')]" ).exists?  )
        
        assert_false( $ff.image(:xpath , "//img[@id='missing_id']").exists?  )
        assert(       $ff.image(:xpath , "//img[@id='square']").exists?  )
        assert(       $ff.image(:xpath , "//img[contains(@id, 'squ')]" ).exists?  )
        
        assert_false( $ff.image(:xpath , "//img[@src='missingsrc.gif']").exists?  )
        
        # BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
        # assert(       $ff.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
        assert(       $ff.image(:xpath , "//img[contains(@src , 'triangle')]" ).exists?  )
        
        assert(       $ff.image(:alt , "circle" ).exists?  )
        assert(       $ff.image(:xpath , "//img[contains(@alt , 'cir')]" ).exists?  )
        
        assert_false(  $ff.image(:alt , "triangle" ).exists?  )
        assert_false(  $ff.image(:xpath , "//img[contains(@alt , 'tri')]" ).exists?  )
    end

    def test_element_by_xpath_class
      # FIXME getting HTMLAnchorElement instead of HTMLImageElement
      # TODO: This should return null if object is not there.
      #element = $ff.element_by_xpath("//img[@name='missing_name']")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[@name='circle']")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[contains(@name , 'circ')]")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      # TODO: This should return null if object is not there.
      #element = $ff.element_by_xpath("//img[@id='missing_id']")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[@id='square']")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[contains(@id, 'squ')]")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[contains(@src , 'triangle')]")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = $ff.element_by_xpath("//img[contains(@alt , 'cir')]")
      assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      # TODO: This should return null if object is not there.
      #element = $ff.element_by_xpath("//img[contains(@alt , 'tri')]")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
    end
    
    def test_image_click
        assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@name='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@id='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@src='no_image_with_this']").click}
        assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@alt='no_image_with_this']").click}

        # test for bug 1882
        $ff.text_field(:name , "text1").clear
        $ff.button(:value , /Pos/ ).click
        assert_equal('clicked' , $ff.text_field(:name , "text1" ).value )

        
        # test for disabled button. Click the button to make it disabled
        $ff.button(:name , 'disable_img').click
        assert( $ff.image(:name , 'disabler_test').disabled )
        
        # Click button again to make it enabled.
        $ff.button(:name , 'disable_img').click
        assert( ! $ff.image(:name , 'disabler_test').disabled )
        
        $ff.image(:src, /button/).click
        assert($ff.text.include?("PASS") )

    end
    

    # TODO: Need to see alternative for this in Mozilla
    #def test_imageHasLoaded
    #    assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@alt='no_image_with_this']").hasLoaded? }
    #    
    #    assert_false( $ff.image(:xpath , "//img[@name='themissingimage']").hasLoaded?  )
    #    assert( $ff.image(:xpath , "//img[@name='circle']").hasLoaded?  )
    #    
    #    assert( $ff.image(:xpath , "//img[@alt='circle']").hasLoaded?  )
    #    # assert( $ff.image(:alt, /cir/ ).hasLoaded?  )
    #end
    
    def test_image_properties
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ff.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
        
        # to string tests -- output should be verified!
        puts $ff.image(:xpath , "//img[@name='circle']").to_s
    end
    
end

