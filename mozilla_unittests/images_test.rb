# feature tests for Images
# revision: $Revision: 1.35 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'
require 'ftools'
require 'webrick'
require 'watir/cookiemanager'

class TC_Images < Test::Unit::TestCase
    include Watir
    
    def setup
        $ie.goto($htmlRoot + "images1.html")
        @saved_img_path = build_path("sample.img.dat");
        clean_saved_image
    end
    
    def teardown
        clean_saved_image
    end
    
    def test_imageExists
        assert( !  $ie.image(:name , "missing_name").exists?  )
        assert(    $ie.image(:name , "circle").exists?  )
        assert(    $ie.image(:name , /circ/ ).exists?  )
        
        assert( !  $ie.image(:id , "missing_id").exists?  )
        assert(    $ie.image(:id , "square").exists?  )
        assert(    $ie.image(:id , /squ/ ).exists?  )
        
        assert( !  $ie.image(:src, "missingsrc.gif").exists?  )
        
        assert(    $ie.image(:src, "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
        assert(    $ie.image(:src , /triangle/ ).exists?  )
        
        assert(    $ie.image(:alt , "circle" ).exists?  )
        assert(    $ie.image(:alt , /cir/ ).exists?  )
        
        assert( !  $ie.image(:alt , "triangle" ).exists?  )
        assert( !  $ie.image(:alt , /tri/ ).exists?  )
        
        assert(    $ie.image(:title, 'square_image').exists? )
        assert( !  $ie.image(:title, 'pentagram').exists? )
    end
    
    def test_image_click
        assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").click}
        assert_raises(UnknownObjectException ) { $ie.image(:alt, "no_image_with_this").click}

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
        assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:alt, "no_image_with_this").hasLoaded? }
        
        assert( ! $ie.image(:name, "themissingimage").hasLoaded?  )
        assert( $ie.image(:name, "circle").hasLoaded?  )
        
        assert( $ie.image(:alt, "circle").hasLoaded?  )
        assert( $ie.image(:alt, /cir/ ).hasLoaded?  )
    end
    
    def test_image_properties
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ie.image(:index, 82).hasLoaded? }
        
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).name }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).id }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).src }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).value }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).height }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).width }
        
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ie.image(:index, 82).fileCreatedDate }
        #assert_raises(UnknownObjectException ) { $ie.image(:index, 82).fileSize }
        
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).alt}
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).title}
        
        assert_equal( ""       , $ie.image(:index, 2).name ) 
        assert_equal( "square" , $ie.image(:index, 2).id )
        assert_match( /square\.jpg/i ,$ie.image(:index, 2).src )
        assert_equal( "" , $ie.image(:index, 2).value )
        assert_equal( "88" , $ie.image(:index, 2).height )
        assert_equal( "88" , $ie.image(:index, 2).width )
        
        # this line fails, as the date is when it is installed on the local oc, not the date the file was really created
        #assert_equal( "03/10/2005" , $ie.image(:index, 2).fileCreatedDate )
        #assert_equal( "788",  $ie.image(:index, 2).fileSize )
       
        # tool tips: alt text + title
        assert_equal('circle' , $ie.image(:index, 6).alt) 
        assert_equal( ""      , $ie.image(:index, 2).alt) 
        assert_equal('square_image', $ie.image(:id, 'square').title)

        # TODO: to string tests -- output should be verified!
        $ie.image(:name  , "circle").to_s
        $ie.image(:index , 2).to_s
    end
    
    #def aatest_image_iterator
    #    assert_equal(6 , $ie.images.length)
    #    assert_equal("" , $ie.images[2].name )
    #    assert_equal("square", $ie.images[2].id )
    #    assert_match(/square/, $ie.images[2].src )
        
    #    index = 1
    #    $ie.images.each do |i|
    #        assert_equal( $ie.image(:index, index).id , i.id )
    #        assert_equal( $ie.image(:index, index).name , i.name )
    #        assert_equal( $ie.image(:index, index).src , i.src )
    #        assert_equal( $ie.image(:index, index).height , i.height )
    #        assert_equal( $ie.image(:index, index).width , i.width )
            
    #        index+=1
    #    end
    #    assert_equal( index-1 , $ie.images.length )
    #end
    
    def aatest_save_local_image
        $ie.images[1].save(build_windows_path("sample.img.dat"))
        assert(File.compare(@saved_img_path, $ie.images[1].src.gsub(/^file:\/\/\//, '')))
    end
    
    def clean_saved_image
        File.delete(@saved_img_path) if (File.exists?(@saved_img_path))
    end
    
    def build_windows_path(part) 
        build_path(part).gsub(/\//, "\\")
    end
    
    def build_path(part) 
        "#{$myDir}/#{part}"
    end
end

