# suite.rb - run all the suggested solutions tests (watir)
# This suite presumes timeclock http server is running on same machine.

require 'test/unit'

$: << File.join( File.dirname( __FILE__ ), '..' )
require 'toolkit/iostring'
require 'toolkit/testhook'
require 'toolkit/table-array'
require 'toolkit/watir-assist'

class Lab2 < Test::Unit::TestCase
  def setup
    ensure_no_user_data 'paul' 
    # Note: test just happens to work whether this is a new or existing user. 
    # It is spec'ed to only work with an existing user...
    @mockout = IOString.new ""
  end
  def test_lab2
    $stdout = @mockout
    load 'lab2w.rb'
    $stdout = STDOUT
    assert_match /COMPLETE\n$/, @mockout

    # verify one job was created and it is no longer running.
    # (presumes ie isn't closed)
    assert_total_job_records 1
    assert_job_record 1, 'ruby article', ''
  end
  def teardown
    $stdout = STDOUT
    $ie.close if $ie
  end
end

class Lab3Part1 < Test::Unit::TestCase
  def test_login_start
    load 'lab3_1.rb'

    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "background", y.job_name(1)
    assert_equal "running", y.status(1)
  end
  def teardown
    $ie.close if $ie
    ensure_no_user_data("ruby")
  end
end

