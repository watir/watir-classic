# Test for Internet Explorer
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'win32ole'
require 'unittests/ie_mock'
require 'test/unit'

class TC_ie < Test::Unit::TestCase
    include Watir

   def setup
      @faked_ie = TestIE.new
   end
    
   def test_waitForIE
      wait_time = 5
    
      @faked_ie.setTimeToWait wait_time
      begin_time = Time.now
      @faked_ie.waitForIE
      elapsed_time = Time.now - begin_time
      assert_number_in_range(elapsed_time, wait_time, 0.5)
   end
    
   # is this correct? 
   def test_getLink_ByIndexReturnsNilOnNoLinks
      assert_nil(@faked_ie.getLink(:index, 1))
      assert_nil(@faked_ie.getLink(:index, 1))
   end
    
   def test_getLink_ByBadHow
      @faked_ie.addLink "foo"
      assert_raise(MissingWayOfFindingObjectException) do
          @faked_ie.getLink(:no_such_mechanism, "verifying error handling")
      end
   end
    
   # is this correct? 
   def test_getLink_ByUrlReturnsNilOnNoLinks
      assert_nil(@faked_ie.getLink(:url, "whatever"))
   end
    
   # is this correct? 
   def test_getLink_ByTextReturnsNilOnNoLinks
      assert_nil(@faked_ie.getLink(:text, "whatever"))
   end
    
   def assert_number_in_range( elapsed_time, expectedTime, tolerance )
      assert( (elapsed_time - expectedTime).abs < tolerance )
   end
end
