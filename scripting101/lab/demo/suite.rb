require 'test/unit'
require '../toolkit/iostring'
require '../toolkit/table-array'
require '../toolkit/testhook'
require '../toolkit'

class DemoSuite < Test::Unit::TestCase
  def test_simple_test
    load 'simple-test.rb'
  end
  def teardown
    $iec.close if $iec
  end
end

