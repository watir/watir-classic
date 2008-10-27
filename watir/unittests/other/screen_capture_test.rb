# feature tests for screen capture
# revision: $Revision:1338 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/screen_capture'

class TC_Capture< Test::Unit::TestCase
  tags :must_be_visible
  include Watir
  include Watir::ScreenCapture
  
  def setup
    delete_captured_files( [ 'jpeg1.jpg' , 'jpeg2.jpg' , 'bmp1.bmp', 'bmp2.bmp' ] )
    browser.goto($htmlRoot + 'buttons1.html' )
    @file_list = []       
  end
  
  def teardown
    delete_captured_files
  end
  
  def delete_captured_files(files=nil )
    files = @file_list unless files
    files.each do |f|
      File.delete( f) if FileTest.exists?( f)
    end
  end
  
  def test_jpeg
    file_name= 'jpeg1.jpg'
    @file_list << file_name
    screen_capture( file_name  )
    assert(FileTest.exist?( file_name) )
    
    file_name= 'jpeg2.jpg'
    @file_list << file_name
    screen_capture( file_name , true  )   # just the active window
    assert(FileTest.exist?( file_name) )
  end
  
  def test_bmp
    file_name= 'bmp1.bmp'
    @file_list << file_name
    screen_capture( file_name , false, true )
    assert(FileTest.exist?( file_name ) )
    
    file_name= 'bmp2.bmp'
    @file_list << file_name
    screen_capture( file_name , true , true )   # just the active window
    assert(FileTest.exist?( file_name) ) 
  end
end

