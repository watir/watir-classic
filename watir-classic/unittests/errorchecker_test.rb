# feature tests for Goto

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_error_checker < Test::Unit::TestCase

  def test_simple_checker
    button_checker = Proc.new do |ie|
      raise RuntimeError, "text 'buttons' is missing"  if ! ie.contains_text(/buttons/)
    end

    browser.add_checker button_checker
    assert_raises( RuntimeError ) { goto_page('forms3.html') }
    assert_nothing_raised { goto_page('buttons1.html') }
  ensure
    browser.disable_checker button_checker
    assert_nothing_raised { goto_page('forms3.html') }
  end

  def test_browser_close_with_failing_checker
    failing_checker = lambda {|ie| raise "Browser should be closed without throwing this exception!"}
    ie = Watir::IE.new
    ie.add_checker failing_checker
    assert_nothing_raised {ie.close}
  ensure
    ie.disable_checker failing_checker
    ie.close if ie.exists?
  end

end
