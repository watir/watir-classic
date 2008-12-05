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
    uses_page "pass.html"
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

  # Open a few browsers so that the test has a few windows to choose
  # from. The test harness has already opened a window that we won't
  # use.
  def open_several_windows
    ["buttons1.html", "whitespace.html"].each do |file|
      @browsers << Browser.start(self.class.html_root + file)
    end
  end
  
  def test_existing_window
    open_several_windows
      
    b1 = Browser.attach(:title , /buttons/i)
    assert_equal("Test page for buttons", b1.title)

    b2 = Browser.attach(:title , "Test page for buttons")
    assert_equal("Test page for buttons", b2.title)
    
    b3 = Browser.attach(:url, /buttons1.html/)
    assert_equal("Test page for buttons", b3.title)
  end
  
  def test_title_and_url_are_correct_after_reload
    uses_page "whitespace.html"
    assert_equal 'Test page for whitespace', browser.title
    assert_match /whitespace.html/, browser.url
    browser.link(:text, 'Login').click
    assert_equal 'Pass Page', browser.title
    assert_match /pass.html/, browser.url
  end

  tag_method :test_working_back_and_forth, :fails_on_firefox
  def test_working_back_and_forth
    open_several_windows
    buttons = Browser.attach(:url, /buttons1.html/)
    whitespace = Browser.attach(:url, /whitespace.html/)
    assert_match /This button is a submit/, buttons.text
    whitespace.link(:text, 'Login').click
    assert_match /pass/i, whitespace.text
  end
end

