# tests for ability to set defaults for Watir
# revision: $Revision$
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'test/unit'
require 'watir'

class TC_Defaults < Test::Unit::TestCase
  include Watir
  
  def test_using_default
    @ie1 = IE.new
    @ie1.speed = :fast
    assert_equal(:fast, @ie1.speed)
    @ie1.speed = :slow
    assert_equal(:slow, @ie1.speed)
    assert_raise(ArgumentError){@ie1.speed = :fubar}
  end    
  
  def teardown
    @ie1.close if @ie1
  end
end