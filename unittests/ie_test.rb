# Test for Internet Explorer
# revision: $Revision$

require 'win32ole'
require 'unittests/ie_mock'
require 'test/unit'

class TC_ie < Test::Unit::TestCase

    def setup()
       @fakedIE = TestIE.new()
    end
    
    def test_waitForIE
      @WAITTIME = 5
	 
       @fakedIE.setTimeToWait(@WAITTIME)
       beginTime = Time.now
       @fakedIE.waitForIE()
       elapseTime = Time.now - beginTime
       assertNumberWithinRange(elapseTime, @WAITTIME, 0.5)
	 end
	 
   def test_getLink_ByIndexReturnsNilOnNoLinks
       assert_raise(UnknownObjectException){@fakedIE.getLink(:index, 1)}
    end
    
   def test_getLink_ByUrlReturnsNilOnNoLinks
       assert_raise(UnknownObjectException){@fakedIE.getLink(:url, "whatever")}
   end
    
    def test_getLink_ByTextReturnsNilOnNoLinks
       assert_raise(UnknownObjectException){@fakedIE.getLink(:text, "whatever")}
    end
    
	 def assertNumberWithinRange( elapseTime, expectedTime, tolerance = 0.0)
		assert( (elapseTime - expectedTime).abs < tolerance )
	 end
    
end
