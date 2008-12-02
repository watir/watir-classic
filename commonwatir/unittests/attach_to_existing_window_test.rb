# feature tests for attaching to existing IE windows
# revision: $Revision: 1417 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_ExistingWindow < Test::Unit::TestCase
  location __FILE__
  include Watir

  def setup 
    @original_timeout = Browser.options[:attach_timeout]
    @browsers = []
  end 

  def teardown
    Browser.set_options :attach_timeout => @original_timeout
    @browsers.each {|x| x.close}
  end

  def test_missing_window
    Browser.set_options :attach_timeout => 0.1
    assert_raises(NoMatchingWindowFoundException) { Browser.attach(:title, "missing") }
    assert_raises(NoMatchingWindowFoundException) { Browser.attach(:title, /missing/) }
    assert_raises(NoMatchingWindowFoundException) { Browser.attach(:url, "missing") }
    assert_raises(NoMatchingWindowFoundException) { Browser.attach(:url, /missing/) }
  end    
  
  def test_existing_window
    # Open a few browsers so that the test has a few windows to choose
    # from. The test harness has already opened a window that we won't
    # use.
    ["pass.html", "buttons1.html", "visibility.html"].each do |file|
      @browsers << Browser.start(self.class.html_root + file)
    end

    b1 = Browser.attach(:title , /buttons/i)
    assert_equal("Test page for buttons", b1.title)

    b2 = Browser.attach(:title , "Test page for buttons")
    assert_equal("Test page for buttons", b2.title)
    
    b3 = Browser.attach(:url, /buttons1.html/)
    assert_equal("Test page for buttons", b3.title)

    #hard to test :url with explicit text
  end
end

