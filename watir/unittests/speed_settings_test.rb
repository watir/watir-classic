# tests for ability to set defaults for Watir
# revision: $Revision$
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'test/unit'
require 'watir'

class TC_instance_options < Test::Unit::TestCase
  include Watir
  
  def test_using_default
    @ie1 = Watir::IE.new
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

class TC_class_options < Test::Unit::TestCase
	include Watir
	@@hide_ie = $HIDE_IE
	def setup
		@previous = Watir::IE.defaults
	end
	def test_class_defaults
		assert_equal({:speed => :slow, :visible => ! @@hide_ie}, IE.defaults)
	end
	def test_change_defaults
		IE.defaults = {:speed => :fast}
		assert_equal(:fast, IE.speed)
		IE.defaults = {:visible => false}
		assert_equal(false, IE.visible)
		IE.defaults = {:speed => :slow}
		assert_equal(:slow, IE.speed)
		IE.defaults = {:visible => true}
		assert_equal(true, IE.visible)
	end
	def test_defaults_affect_on_instance
		IE.defaults = {:speed => :fast}
		@ie1 = IE.new
		assert_equal(:fast, @ie1.speed)
		IE.defaults = {:speed => :slow}
		@ie2 = IE.new
		assert_equal(:slow, @ie2.speed)
	end
	def teardown
		IE.defaults = @previous
		@ie1.close if @ie1
		@ie2.close if @ie2
	end
end