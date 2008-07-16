# feature tests for Images
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'ftools'
require 'webrick'

class TC_Images < Test::Unit::TestCase
    include FireWatir
    
    def setup
        $ff.goto($htmlRoot + "images1.html")
        @saved_img_path = build_path("sample.img.dat");
        clean_saved_image
    end
    
    def teardown
        clean_saved_image
    end
#    def test_show_all_objects
#        $ff.show_all_objects
#    end
    
    def test_imageExists
        assert( !  $ff.image(:name , "missing_name").exists?  )
        assert(    $ff.image(:name , "circle").exists?  )
        assert(    $ff.image(:name , /circ/ ).exists?  )
        
        assert( !  $ff.image(:id , "missing_id").exists?  )
        assert(    $ff.image(:id , "square").exists?  )
        assert(    $ff.image(:id , /squ/ ).exists?  )
        
        assert( !  $ff.image(:src, "missingsrc.gif").exists?  )
         
        assert(    $ff.image(:src, /images\/triangle.jpg/).exists?  )
        assert(    $ff.image(:src , /triangle/ ).exists?  )
        
        assert(    $ff.image(:alt , "circle" ).exists?  )
        assert(    $ff.image(:alt , /cir/ ).exists?  )
        
        assert( !  $ff.image(:alt , "triangle" ).exists?  )
        assert( !  $ff.image(:alt , /tri/ ).exists?  )
        
        assert(    $ff.image(:title, 'square_image').exists? )
        assert( !  $ff.image(:title, 'pentagram').exists? )
    end
    
    def test_image_click
        assert_raises(UnknownObjectException ) { $ff.image(:name, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ff.image(:id, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ff.image(:src, "no_image_with_this").click}
        assert_raises(UnknownObjectException ) { $ff.image(:alt, "no_image_with_this").click}

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
        #assert($ff.text.include?("PASS") )
        assert($ff.contains_text("PASS") )
    end
    
    # TODO: Need to see alternative for this in Mozilla
    #def test_imageHasLoaded
    #    assert_raises(UnknownObjectException ) { $ff.image(:name, "no_image_with_this").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:id, "no_image_with_this").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:src, "no_image_with_this").hasLoaded? }
    #    assert_raises(UnknownObjectException ) { $ff.image(:alt, "no_image_with_this").hasLoaded? }
    #    
    #    assert( ! $ff.image(:name, "themissingimage").hasLoaded?  )
    #    assert( $ff.image(:name, "circle").hasLoaded?  )
    #    
    #    assert( $ff.image(:alt, "circle").hasLoaded?  )
    #    assert( $ff.image(:alt, /cir/ ).hasLoaded?  )
    #end
    
    def test_image_properties
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ff.image(:name, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ff.image(:id, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ff.image(:src, "no_image_with_this").hasLoaded? }
        #assert_raises(UnknownObjectException ) { $ff.image(:index, 82).hasLoaded? }
        
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).name }
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).id }
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).src }
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).value }
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).height }
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).width }
        
        # TODO: Need to see alternative for this in Mozilla
        #assert_raises(UnknownObjectException ) { $ff.image(:index, 82).fileCreatedDate }
        #assert_raises(UnknownObjectException ) { $ff.image(:index, 82).fileSize }
        
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).alt}
        assert_raises(UnknownObjectException ) { $ff.image(:index, 82).title}
        
        assert_equal( ""       , $ff.image(:index, 2).name ) 
        assert_equal( "square" , $ff.image(:index, 2).id )
        assert_match( /square\.jpg/i ,$ff.image(:index, 2).src )
        assert_equal( "" , $ff.image(:index, 2).value )
        assert_equal( "88" , $ff.image(:index, 2).height )
        assert_equal( "88" , $ff.image(:index, 2).width )
        
        # this line fails, as the date is when it is installed on the local oc, not the date the file was really created
        #assert_equal( "03/10/2005" , $ff.image(:index, 2).fileCreatedDate )
        #assert_equal( "788",  $ff.image(:index, 2).fileSize )
       
        # tool tips: alt text + title
        assert_equal('circle' , $ff.image(:index, 6).alt) 
        assert_equal( ""      , $ff.image(:index, 2).alt) 
        assert_equal('square_image', $ff.image(:id, 'square').title)

        # to string tests -- output should be verified!
        puts $ff.image(:name  , "circle").to_s
        puts  $ff.image(:index , 2).to_s
    end
    
    def test_image_iterator
        assert_equal(6 , $ff.images.length)
        assert_equal("" , $ff.images[2].name )
        assert_equal("square", $ff.images[2].id )
        assert_match(/square/, $ff.images[2].src )
        
        index = 1
        $ff.images.each do |i|
            assert_equal( $ff.image(:index, index).id , i.id )
            assert_equal( $ff.image(:index, index).name , i.name )
            assert_equal( $ff.image(:index, index).src , i.src )
            assert_equal( $ff.image(:index, index).height , i.height.to_s )
            assert_equal( $ff.image(:index, index).width , i.width.to_s )
            
            index+=1
        end
        assert_equal( index-1 , $ff.images.length )
    end
    
    #def test_save_local_image
    #   $ff.images[1].save(build_windows_path("sample.img.dat"))
    #    assert(File.compare(@saved_img_path, $ff.images[1].src.gsub(/^file:\/\/\//, '')))
    #end
    
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

class TC_Images_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showImages
    $ff.goto($htmlRoot + "images1.html")
    $stdout = @mockout
    $ff.showImages
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 6 images
image: name: 
         id: 
        src: images/triangle.jpg
      index: 1
image: name: 
         id: square
        src: images/square.jpg
      index: 2
image: name: circle
         id: 
        src: images/circle.jpg
      index: 3
image: name: themissingimage
         id: 
        src: images/missing.jpg
      index: 4
image: name: disabler_test
         id: 
        src: images/button.jpg
      index: 5
image: name: 
         id: 
        src: images/circle.jpg
      index: 6
END_OF_MESSAGE
  end
end

