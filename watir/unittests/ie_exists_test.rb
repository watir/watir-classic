# test IE#exists?

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_IENotExists < Test::Unit::TestCase 
  def setup
    @ie = Watir::IE.new
  end

  def test_some_one_else_closed_it
    @ie.ie.quit
    sleep 0.3 # give it some time to close
    assert_false(@ie.exists?)
  end    
end
