# Unit Test for Internet Explorer

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'unittests/ie_mock'

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
  
  def test_getLink_ByIndexReturnsNilOnNoLinks
    assert_false(@faked_ie.link(:index, 0).exists?)
  end
  
  def test_getLink_ByBadHow
    @faked_ie.addLink "foo"
    assert_raise(UnknownObjectException) do
      @faked_ie.link(:no_such_mechanism, "verifying error handling").click
    end
  end

  def test_execute_script
    script = %q[
      var x = 'something';
      var y = " else";
      x + y;
    ]
    assert_equal "something else", browser.execute_script(script)
  end
  
  def test_getLink_ByUrlReturnsNilOnNoLinks
    assert_false(@faked_ie.link(:url, "whatever").exists?)
  end
    
  def test_getLink_ByTextReturnsNilOnNoLinks
    assert_false(@faked_ie.link(:text, "whatever").exists?)
  end

end

