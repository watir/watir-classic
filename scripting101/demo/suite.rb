$: << File.join( File.dirname( __FILE__ ), '..' )
require 'test/unit'
require 'toolkit'

class DemoSuite < Test::Unit::TestCase
  def teardown
    $iec.close if $iec
  end
  def test_simple_test
    load 'simple-test.rb'
  end
  def test_all_buttons
    load 'all-buttons.rb'
  end
end

