# feature tests for navigation errors
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_NavigateException < Test::Unit::TestCase
  include Watir
  
  def test_http_errors
    assert_raises(NavigationException) { $ie.goto('http://localhost:3001') }        # Cannot find server or DNS Error
    assert_raises(NavigationException) { $ie.goto('http://www.fxruby.org/dfdf' ) }  # HTTP 404 - File not found
  end
end