require 'test/unit'
require 'toolkit/iec-assist'
require 'toolkit/iostring'
require 'toolkit/timeclock-assist'

class TestInterface < Test::Unit::TestCase

  def teardown
    $iec.close if $iec
  end

  def setup
    ie_load( 'sample_page2.html' )
  end

  def test_very_simple
    buttons = form{|f| f.action == 'pause_or_stop_day'}.elements
    assert_equal( 3, buttons.length )
    assert_equal( 'pause_day', buttons['pause_day'].name )
    assert_equal( 'pause_day', buttons.item(1).name )
  end
    
  def test_simple
    element = form{|f| f.action == 'pause_or_stop_day'}.element{|e| e.name == 'pause_day' }
    assert_equal( 'Pause the Day', element.value)
  end

end

=begin
  def test_show_elements
    form(0).elements
name: session value: 135694616
name: pause_day value: Pause the Day
name: stop_day value: Stop the Day
=> nil

irb(main):023:0> elements.each {|e| puts "name: #e.name value #e.value"}
name: session value 135694616
name: pause_day value Pause the Day
name: stop_day value Stop the Day
=> nil

end
=end


