require 'test/unit'
require '../toolkit/iostring'
require '../toolkit/table-array'
require '../toolkit/testhook'
require '../toolkit'

class Lab3dash4Test < Test::Unit::TestCase
  def setup
    # start with user with no time records
    ensure_no_user_data("ruby")
    @mockout = IOString.new ""
  end

  def test_simple_test
    $stdout = @mockout
    load 'simple-test.rb'
    $stdout = STDOUT
    expect "PASS"
    expect "Recent Records"
    expect "job2"
    expect_match /M$/
    expect_match /hours$/
    expect ""
    expect "job1"
    expect_match /M$/
    expect_match /hours$/
    expect ""
    expect nil # end of file
  end
  def teardown
    $stdout = STDOUT
    $iec.close if $iec
  end
end

