# feature tests for Images
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'ftools'
require 'webrick'
require 'watir/cookiemanager'

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

    def test_save_local_image
        gotoImagePage()
        safe_file_block(1) {
            assert(File.compare("sample.img.dat", $ie.images[1].src.gsub(/^file:\/\/\//, '')))
        }
    end

    def test_save_local_image_overwrites
        gotoImagePage()
        safe_file_block(1,2) {
            assert(File.compare("sample.img.dat", $ie.images[2].src.gsub(/^file:\/\/\//, '')))
        }
    end

    def test_save_remote_image
        run_webrick {
            goto_local_served_page
            safe_file_block(1) {
                assert(File.compare("sample.img.dat", build_path("html/images/triangle.jpg")))
            }
        }
    end

    def test_save_remote_image_overwrites
        run_webrick {
            goto_local_served_page
            safe_file_block(1,2) {
                assert(File.compare("sample.img.dat", build_path("html/images/square.jpg")))
            }
        }
    end

    def test_not_found_in_cache_throws
        run_webrick {
            goto_local_served_page
            Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(0x0020)
            assert_raises(CacheItemNotFound ) { $ie.images[1].save("sample.img.dat") }
        }
    end

    def test_most_recent_returned_when_duplicates
        run_webrick {
            goto_local_served_page
        }
        File.copy(build_path("html/images/square.jpg"), build_path("html/images/triangle.jpg"))
        begin
            run_webrick(34000) {
                goto_local_served_page
                safe_file_block(1) {
                    assert(File.compare("sample.img.dat", build_path("html/images/square.jpg")))
                }
            }
        ensure
            File.copy(build_path("html/images/originaltriangle.jpg"), build_path("html/images/triangle.jpg"))
        end
    end

    def goto_local_served_page
        $ie.goto("http://localhost:#{@port}/images1.html")
    end

    def safe_file_block(*imgstosave)
        File.unlink("sample.img.dat") if (File.exists?("sample.img.dat"))
        begin
            imgstosave.each {|imgidx| $ie.images[imgidx].save("sample.img.dat")}
            yield
        ensure
            File.unlink("sample.img.dat") if (File.exists?("sample.img.dat"))
        end
    end
    
    def build_path(part) 
      dir = part
      dir = "unittests/" + dir if ($0 != __FILE__)
      dir
    end

    def run_webrick(port = 33000)
        @port = port
        server = WEBrick::HTTPServer.new(:Port => port,
                                         :DocumentRoot => build_path("html"),
                                         :Logger => WEBrick::Log.new(nil, WEBrick::Log::FATAL ))
        begin
            runner = Thread.new(server) {|svr| svr.start()}
            yield
        ensure
            server.stop()
            runner.join()
            server.shutdown()
        end
    end
end

