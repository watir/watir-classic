# test IE#exists?
# revision: $Revision: 962 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_IE_Exists < Test::Unit::TestCase 
  tags :fails_on_firefox, :new
  def setup
    @ie = Watir::IE.new
  end
  def teardown
    @ie.close
  end
  def test_exists
    assert(@ie.exists?)
  end
end

class TC_IENotExists < Test::Unit::TestCase 
  tags :fails_on_firefox, :new
  def setup
    @ie = Watir::IE.new
  end
  def test_we_closed_it
    @ie.close
    assert(!@ie.exists?)
  end
  def test_some_one_else_closed_it
    @ie.ie.quit
    sleep 0.3 # give it some time to close
    assert(!@ie.exists?)
  end    
end