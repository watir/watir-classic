# feature tests for attaching to existing IE windows
# revision: $Revision: 1417 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
#require 'watir/ie'
require 'unittests/setup'

class TC_ExistingWindow < Test::Unit::TestCase
  location __FILE__

  def setup
    # Open a few browsers so that the test has a few windows to choose
    # from. The test harness has already opened a window that we won't
    # use.
    Watir::Browser.new.goto(self.class.html_root + "pass.html")
    Watir::Browser.new.goto(self.class.html_root + "buttons1.html")
    Watir::Browser.new.goto(self.class.html_root + "visibility.html")
  end 

  def teardown
    Watir::Browser.reset_attach_timeout
    Watir::Browser.attach(:url, /pass/).close
    Watir::Browser.attach(:url, /buttons/).close
    Watir::Browser.attach(:url, /visibility/).close
  end

  def test_missing_window
    Watir::Browser.attach_timeout = 0.1
    assert_raises(NoMatchingWindowFoundException) { Watir::Browser.attach(:title, "missing") }
    assert_raises(NoMatchingWindowFoundException) { Watir::Browser.attach(:title, /missing/) }
    assert_raises(NoMatchingWindowFoundException) { Watir::Browser.attach(:url, "missing") }
    assert_raises(NoMatchingWindowFoundException) { Watir::Browser.attach(:url, /missing/) }
  end    
  
  def test_existing_window

    br = Watir::Browser.attach(:title , /buttons/i)
    assert_equal("Test page for buttons", br.title)

    br = Watir::Browser.attach(:title , "Test page for buttons")
    assert_equal("Test page for buttons", br.title)
    
    br = Watir::Browser.attach(:url, /buttons1.html/)
    assert_equal("Test page for buttons", br.title)
    
    #hard to test :url with explicit text
  end
end

