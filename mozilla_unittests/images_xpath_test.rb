# feature tests for Images
# revision: $Revision: 1.2 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'
require 'ftools'
require 'webrick'
require 'watir/cookiemanager'

class TC_Images_XPath < Test::Unit::TestCase
    include Watir
    
    def setup
        gotoImagePage
    end
    
    def gotoImagePage()
        $ie.goto($htmlRoot + "images1.html")
    end

    def test_imageExists
        assert_false( $ie.image(:xpath , "//img[@name='missing_name']").exists?  )
        assert(       $ie.image(:xpath , "//img[@name='circle']").exists?  )
        assert(       $ie.image(:xpath , "//img[contains(@name , 'circ')]" ).exists?  )
        
        assert_false( $ie.image(:xpath , "//img[@id='missing_id']").exists?  )
        assert(       $ie.image(:xpath , "//img[@id='square']").exists?  )
        assert(       $ie.image(:xpath , "//img[contains(@id, 'squ')]" ).exists?  )
        
        assert_false( $ie.image(:xpath , "//img[@src='missingsrc.gif']").exists?  )
        
        # BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
        # assert(       $ie.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
        assert(       $ie.image(:xpath , "//img[contains(@src , 'triangle')]" ).exists?  )
        
        assert(       $ie.image(:alt , "circle" ).exists?  )
        assert(       $ie.image(:xpath , "//img[contains(@alt , 'cir')]" ).exists?  )
        
        assert_false(  $ie.image(:alt , "triangle" ).exists?  )
        assert_false(  $ie.image(:xpath , "//img[contains(@alt , 'tri')]" ).exists?  )
    end
    
    def test_image_click
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']").click }
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']").click}
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@alt='no_image_with_this']").click}

        # test for bug 1882
        $ie.text_field(:name , "text1").clear
        $ie.button(:value , /Pos/ ).click
        assert_equal('clicked' , $ie.text_field(:name , "text1" ).value )

        
        # test for disabled button. Click the button to make it disabled
        $ie.button(:name , 'disable_img').click
        assert( $ie.image(:name , 'disabler_test').disabled )
        
        # Click button again to make it enabled.
        $ie.button(:name , 'disable_img').click
        assert( ! $ie.image(:name , 'disabler_test').disabled )
        
        $ie.image(:src, /button/).click
        assert($ie.text.include?("PASS") )

    end
    

    # TODO: Need to see alternative for this in Mozilla
    def aatest_imageHasLoaded
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@alt='no_image_with_this']").hasLoaded? }
        
        assert_false( $ie.image(:xpath , "//img[@name='themissingimage']").hasLoaded?  )
        assert( $ie.image(:xpath , "//img[@name='circle']").hasLoaded?  )
        
        assert( $ie.image(:xpath , "//img[@alt='circle']").hasLoaded?  )
        # assert( $ie.image(:alt, /cir/ ).hasLoaded?  )
    end
    
    def test_image_properties
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@name='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@id='no_image_with_this']").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ie.image(:xpath , "//img[@src='no_image_with_this']").hasLoaded? }
        
        # to string tests -- output should be verified!
        puts $ie.image(:xpath , "//img[@name='circle']").to_s
    end
    
end

