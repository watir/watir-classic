# tests for ability to set defaults for Watir
# revision: $Revision$
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_instance_options < Test::Unit::TestCase
  tags :fails_on_firefox
  
  def setup
    @ie4 = Watir::IE.new    
  end
  
  def test_using_default
    @ie4.speed = :fast
    assert_equal(:fast, @ie4.speed)
    @ie4.speed = :slow
    assert_equal(:slow, @ie4.speed)
    @ie4.speed = :zippy
    assert_equal(:zippy, @ie4.speed)
   
    assert_raise(ArgumentError){@ie4.speed = :fubar}
  end

  def teardown
    @ie4.close if @ie4.exists?
  end
end

class TC_class_options < Test::Unit::TestCase
  tags :fails_on_firefox
	include Watir
	@@hide_ie = $HIDE_IE
	def setup
		@previous = IE.options
	end
	def test_class_defaults
		assert_equal({:speed => IE.speed, :visible => IE.visible}, IE.options)
	end
	def test_change_defaults
		IE.set_options(:speed => :fast)
		assert_equal(:fast, IE.speed)
		IE.set_options(:visible => false)
		assert_equal(false, IE.visible)
		IE.set_options(:speed => :slow)
		assert_equal(:slow, IE.speed)
		IE.set_options(:visible => true)
		assert_equal(true, IE.visible)
	end
	def test_defaults_affect_on_instance
		IE.set_options(:speed => :fast)
		@ie1 = IE.new
		assert_equal(:fast, @ie1.speed)
		IE.set_options(:speed => :slow)
		@ie2 = IE.new
		assert_equal(:slow, @ie2.speed)
    IE.set_options(:speed => :zippy)
    @ie3 = IE.new
    assert_equal(:zippy, @ie3.speed)
	end
	def teardown
		IE.set_options @previous
		@ie1.close if @ie1
		@ie2.close if @ie2
    @ie3.close if @ie3
	end
end