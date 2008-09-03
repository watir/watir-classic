# feature tests for minimizing and maximizing IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_MinMax< Test::Unit::TestCase
  def setup
    goto_page 'pass.html'
  end        
  def teardown
    $ie.restore
  end
  def test_minimimum
    $ie.minimize
  end
  def test_maximum
    $ie.maximize
  end
  def test_front
    assert $ie.front?
    ie2 = Watir::IE.start($htmlRoot + 'blankpage.html')
    assert ie2.front?
    assert ! $ie.front?
    $ie.bring_to_front
    assert $ie.front?
    ie2.close
  end
end

