# Test for Internet Explorer
# revision: $Revision$

require 'unittests/ie_mock'
require 'unittests/setup'

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
	 
	 def assertNumberWithinRange( elapseTime, expectedTime, tolerance = 0.0)
		assert( (elapseTime - expectedTime).abs < tolerance )
	 end
	 
end

#require 'watir.rb'