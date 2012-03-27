$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'commonwatir', 'lib')
require 'test/unit'
require 'watir/ie'

class TC_NewProcess < Test::Unit::TestCase
  def test_new_process_single_window
    assert_nothing_raised {
      ie = Watir::IE.new_process
      ie.goto 'www.yahoo.com'
      ie.close
    }
  end
  def test_new_process_multiple_windows
    assert_nothing_raised {
      ie1 = Watir::IE.new_process
      ie1.goto 'www.yahoo.com'
      ie2 = Watir::IE.new_process
      ie2.goto 'www.google.com'
      ie1.close
      ie2.close
    }
  end
end
