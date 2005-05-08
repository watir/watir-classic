# suite.rb - run all the suggested solutions tests
# Presumes timeclock http server is already running on same machine.

require 'test/unit'

$LOAD_PATH << File.join( File.dirname( __FILE__ ), '..' )
require 'toolkit/iostring'
require 'toolkit/testhook'
require 'toolkit/timeclock-recent-records'
require 'toolkit/watir-assist'

require 'watir'

class Lab2 < Test::Unit::TestCase
  def setup
    ensure_no_user_data 'paul' 
    # Note: test just happens to work whether this is a new or existing user. 
    # It is spec'ed to only work with an existing user...
    @mockout = IOString.new ""
  end
  def test_lab2
    $stdout = @mockout
    load 'lab2.rb'
    $stdout = STDOUT
    assert_match /COMPLETE\n$/, @mockout

    # verify one job was created and it is no longer running.
    # (presumes ie isn't closed)
    $ie = Watir::IE.attach(:title, /Paul's Timeclock/)
    assert_total_job_records 1
    assert_job_record 1, 'ruby article', ''
  end
  def teardown
    $stdout = STDOUT
    $ie = Watir::IE.attach(:title, /Timeclock/)
    $ie.close if $ie
  end
end

class Lab3 < Test::Unit::TestCase

  def test_login_start
    load 'lab3_1.rb'
    $ie = Watir::IE.attach(:title, /Timeclock/)
    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "background", y.job_name(1)
    assert_equal "running", y.status(1)
  end

  def test_start_stop
    load 'lab3_2.rb'
    $ie = Watir::IE.attach(:title, /Timeclock/)
    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "foreground", y.job_name(1)
    assert_equal "", y.status(1)
  end

  def test_two_jobs
    load 'lab3_3.rb'
    $ie = Watir::IE.attach(:title, /Timeclock/)
    y = get_results_table_array
    assert_equal 3, y.length
    assert_equal "job2", y.job_name(1)
    assert_equal "running", y.status(1)
    assert_equal "job1", y.job_name(2)
    assert_equal "paused", y.status(2)
  end
  
  def teardown
    $ie = Watir::IE.attach(:title, /Timeclock/)
    $ie.close if $ie
    ensure_no_user_data("ruby")
  end
end

class Lab4 < Test::Unit::TestCase
  def setup
    ensure_no_user_data 'ruby' 
    @mockout = IOString.new ""
  end
  def test_lab4_1
    $stdout = @mockout
    load 'lab4_1.rb'
    $stdout = STDOUT
    assert_match /PASS - job started\n/, @mockout
    assert_match /PASS - background job is running\n/, @mockout
  end
  def teardown
    $stdout = STDOUT
    $ie = Watir::IE.attach(:title, /Timeclock/)
    $ie.close if $ie
  end
end