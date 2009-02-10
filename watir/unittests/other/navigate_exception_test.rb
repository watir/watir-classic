# feature tests for navigation errors
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/contrib/page_checker' 
#  To add checkers, call the ie.add_checker method
#
#  ie.

class TC_NavigateException < Test::Unit::TestCase
  include Watir
  
  def setup
    browser.add_checker(PageCheckers::NAVIGATION_CHECKER)
  end
  def teardown
    browser.disable_checker(PageCheckers::NAVIGATION_CHECKER)
  end
  
  def test_http_errors
    assert_raises(NavigationException) { browser.goto('http://localhost:3001') }        # Cannot find server or DNS Error
    assert_raises(NavigationException) { browser.goto('http://www.fxruby.org/dfdf' ) }  # HTTP 404 - File not found
  end
end