# feature tests for Images
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Images < Test::Unit::TestCase
    include Watir

    def setup
        gotoImagePage
    end

    def gotoImagePage()
        $ie.goto($htmlRoot + "images1.html")
    end



    def test_imageExists



        assert_false( $ie.image(:name , "missing_name").exists?  )
        assert(       $ie.image(:name , "circle").exists?  )
        assert(       $ie.image(:name , /circ/ ).exists?  )



        assert_false( $ie.image(:id , "missing_id").exists?  )
        assert(       $ie.image(:id , "square").exists?  )
        assert(       $ie.image(:id , /squ/ ).exists?  )


        assert_false( $ie.image(:src, "missingsrc.gif").exists?  )

# BP -- This fails for me but not for Paul. It doesn't make sense to me that it should pass.  
#        assert(       $ie.image(:src , "file:///#{$myDir}/html/images/triangle.jpg").exists?  )
        assert(       $ie.image(:src , /triangle/ ).exists?  )

        assert(       $ie.image(:alt , "circle" ).exists?  )
        assert(       $ie.image(:alt , /cir/ ).exists?  )

        assert_false(  $ie.image(:alt , "triangle" ).exists?  )
        assert_false(  $ie.image(:alt , /tri/ ).exists?  )



    end


    def test_image_click
        assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").click }
        assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").click}
        assert_raises(UnknownObjectException ) { $ie.image(:alt, "no_image_with_this").click}


        $ie.image(:src, /button/).click

        assert($ie.contains_text("PASS") )


    end

    def test_imageHasLoaded
        assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:alt, "no_image_with_this").hasLoaded? }


        assert_false( $ie.image(:name, "themissingimage").hasLoaded?  )
        assert( $ie.image(:name, "circle").hasLoaded?  )

        assert( $ie.image(:alt, "circle").hasLoaded?  )
        assert( $ie.image(:alt, /cir/ ).hasLoaded?  )


    end

    def test_image_properties

        assert_raises(UnknownObjectException ) { $ie.image(:name, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:id, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:src, "no_image_with_this").hasLoaded? }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).hasLoaded? }

        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).name }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).id }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).src }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).value }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).height }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).width }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).fileCreatedDate }
        assert_raises(UnknownObjectException ) { $ie.image(:index, 82).fileSize }

        assert_equal( "image"  , $ie.image(:index, 2).type ) 
        assert_equal( ""       , $ie.image(:index, 2).name ) 
        assert_equal( "square" , $ie.image(:index, 2).id )
        assert_match( /square\.jpg/i ,$ie.image(:index, 2).src )
        assert_equal( "" , $ie.image(:index, 2).value )
        assert_equal( "88" , $ie.image(:index, 2).height )
        assert_equal( "88" , $ie.image(:index, 2).width )

        # this line fails, as the date is when it is installed on the local oc, not the date the file was really created
        #assert_equal( "03/10/2005" , $ie.image(:index, 2).fileCreatedDate )
        assert_equal( "788",  $ie.image(:index, 2).fileSize )

        puts"--------------------- To String tests -------------------"

        puts $ie.image(:name  , "circle").to_s
        puts $ie.image(:index , 2).to_s
    end

    def test_image_iterator

        assert_equal(6 , $ie.images.length)
        assert_equal("" , $ie.images[2].name )
        assert_equal("square" , $ie.images[2].id )
        assert_match(/square/ , $ie.images[2].src )

        index = 1
        $ie.images.each do |i|
            assert_equal( $ie.image(:index, index).id , i.id )
            assert_equal( $ie.image(:index, index).name , i.name )
            assert_equal( $ie.image(:index, index).src , i.src )
            assert_equal( $ie.image(:index, index).height , i.height )
            assert_equal( $ie.image(:index, index).width , i.width )

            index+=1
        end
        assert_equal( index-1 , $ie.images.length )

    end
end

