# Unit Test for Internet Explorer

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'watir/win32ole'
require 'unittests/ie_mock'
require 'test/unit'

class TC_ie < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    @faked_ie = TestIE.new
  end
  
  def test_waitForIE
    wait_time = 1
    #      @faked_ie.logger.level = Logger::DEBUG
    
    @faked_ie.setTimeToWait wait_time
    begin_time = Time.now
    @faked_ie.wait
    elapsed_time = Time.now - begin_time
    assert_in_delta(wait_time, elapsed_time, 0.5)
  end
  
  # is this correct? 
  def test_getLink_ByIndexReturnsNilOnNoLinks
    assert_nil(@faked_ie.locate_tagged_element('A', :index, 1))
    assert_nil(@faked_ie.locate_tagged_element('A', :index, 1))
  end
  
  def test_getLink_ByBadHow
    @faked_ie.addLink "foo"
    assert_raise(MissingWayOfFindingObjectException) do
      @faked_ie.locate_tagged_element('A', :no_such_mechanism, "verifying error handling")
    end
  end
  
  # is this correct? 
  def test_getLink_ByUrlReturnsNilOnNoLinks
    assert_nil(@faked_ie.locate_tagged_element('A', :url, "whatever"))
  end
  
  # is this correct? 
  def test_getLink_ByTextReturnsNilOnNoLinks
    assert_nil(@faked_ie.locate_tagged_element('A', :text, "whatever"))
  end

end

