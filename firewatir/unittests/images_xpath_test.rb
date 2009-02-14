# feature tests for Images
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'ftools'
require 'webrick'

class TC_Images_XPath < Test::Unit::TestCase
    
    
    def setup
        gotoImagePage
    end
    
    def gotoImagePage()
        goto_page("images1.html")
    end

    def test_imageExists
        assert_false( browser.image(:xpath , "//img[@name='missing_name']").exists?  )
        assert(       browser.image(:xpath , "//img[@name='circle']").exists?  )
        assert(       browser.image(:xpath , "//img[contains(@name , 'circ')]" ).exists?  )
        
        assert_false( browser.image(:xpath , "//img[@id='missing_id']").exists?  )
        assert(       browser.image(:xpath , "//img[@id='square']").exists?  )
        assert(       browser.image(:xpath , "//img[contains(@id, 'squ')]" ).exists?  )
        
        assert_false( browser.image(:xpath , "//img[@src='missingsrc.gif']").exists?  )
        
        # BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
        # assert(       browser.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
        assert(       browser.image(:xpath , "//img[contains(@src , 'triangle')]" ).exists?  )
        
        assert(       browser.image(:alt , "circle" ).exists?  )
        assert(       browser.image(:xpath , "//img[contains(@alt , 'cir')]" ).exists?  )
        
        assert_false(  browser.image(:alt , "triangle" ).exists?  )
        assert_false(  browser.image(:xpath , "//img[contains(@alt , 'tri')]" ).exists?  )
    end

    tag_method :test_element_by_xpath_class, :fails_on_ie
    def test_element_by_xpath_class
      # FIXME getting HTMLAnchorElement instead of HTMLImageElement
      # TODO: This should return null if object is not there.
      #element = browser.element_by_xpath("//img[@name='missing_name']")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = browser.element_by_xpath("//img[@name='circle']")
      assert_class(element, 'Image')
      element = browser.element_by_xpath("//img[contains(@name , 'circ')]")
      assert_class(element, 'Image')
      # TODO: This should return null if object is not there.
      #element = browser.element_by_xpath("//img[@id='missing_id']")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
      element = browser.element_by_xpath("//img[@id='square']")
      assert_class(element, 'Image')
      element = browser.element_by_xpath("//img[contains(@id, 'squ')]")
      assert_class(element, 'Image')
      element = browser.element_by_xpath("//img[contains(@src , 'triangle')]")
      assert_class(element, 'Image')
      element = browser.element_by_xpath("//img[contains(@alt , 'cir')]")
      assert_class(element, 'Image')
      # TODO: This should return null if object is not there.
      #element = browser.element_by_xpath("//img[contains(@alt , 'tri')]")
      #assert(element.instance_of?(Image),"element class should be #{Image}; got #{element.class}")
    end
    
    def test_image_click
        assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']").click}
        assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@alt='no_image_with_this']").click}

        # test for bug 1882
        browser.text_field(:name , "text1").clear
        browser.button(:value , /Pos/ ).click
        assert_equal('clicked' , browser.text_field(:name , "text1" ).value )

        
        # test for disabled button. Click the button to make it disabled
        browser.button(:name , 'disable_img').click
        assert( browser.image(:name , 'disabler_test').disabled )
        
        # Click button again to make it enabled.
        browser.button(:name , 'disable_img').click
        assert( ! browser.image(:name , 'disabler_test').disabled )
        
        browser.image(:src, /button/).click
        assert(browser.text.include?("PASS") )

    end
    

    # TODO: Need to see alternative for this in Mozilla
    #def test_imageHasLoaded
    #    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@alt='no_image_with_this']").hasLoaded? }
    #    
    #    assert_false( browser.image(:xpath , "//img[@name='themissingimage']").hasLoaded?  )
    #    assert( browser.image(:xpath , "//img[@name='circle']").hasLoaded?  )
    #    
    #    assert( browser.image(:xpath , "//img[@alt='circle']").hasLoaded?  )
    #    # assert( browser.image(:alt, /cir/ ).hasLoaded?  )
    #end
    
    def test_image_properties
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { browser.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
        
        # to string tests -- output should be verified!
        puts browser.image(:xpath , "//img[@name='circle']").to_s
    end
    
end

