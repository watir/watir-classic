# lab-suite.rb - run all the suggested solutions tests
# This suite presumes timeclock http server is running on same machine.

require 'test/unit'
require '../toolkit/iostring'
require '../toolkit/table-array'
require '../toolkit/testhook'

### Utility functions & classes
class NilClass
  def strip
    nil
  end
end

def initialize_user (user, initial_job)
  # presumes user is not already initialized
  require 'toolkit/iec-assist'
  start_ie("http://localhost:8080")
  login_form = get_forms[0]
  login_form.name = user
  login_form.submit
  $iec.wait
  
  job_form = get_forms[0]
  job_form.name = initial_job
  job_form.submit
  $iec.wait
  sleep 2
  $iec.close
end

### Tests

class Lab2CompleteTest < Test::Unit::TestCase
  def setup
    ensure_no_user_data("bret")
    # Note: test just happens to work whether this is a new or existing user. 
    # It is spec'ed to only work with an existing user...
    @mockout = IOString.new ""
  end
  def test_lab2
    $stdout = @mockout
    load 'lab2.rb'
    $stdout = STDOUT
    assert_equal "COMPLETE\n", @mockout

    # verify one job was created and it is no longer running.
    # (presumes ie isn't closed)
    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "ruby article", y.job_name(1)
    assert_equal "", y.status(1)
  end
  def teardown
    $stdout = STDOUT
    $iec.close if $iec
  end
end

class Lab3dash4Test < Test::Unit::TestCase
  def setup
    # start with user with no time records
    ensure_no_user_data("ruby")
    @mockout = IOString.new ""
  end

  def expect string
    assert_equal string, @mockout.readline!.strip
  end
  def expect_match regexp
    assert_match regexp, @mockout.readline!.strip
  end

  def test_check_records
    $stdout = @mockout
    load 'check-records.rb'
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

class LittleTest < Test::Unit::TestCase
  def setup
    ensure_no_user_data("STANZ")
    initialize_user "STANZ", "background"
    @mockout = IOString.new ""
  end
  def test_test1
    $stdout = @mockout
    load 'test1.rb'
    sleep 2
    $stdout = STDOUT
    # assert_no_match /FAIL/, @mockout 
    assert @mockout !~ /FAIL/
  end
  def teardown
    $stdout = STDOUT
    $iec.close if $iec
  end
end

class LoginStart < Test::Unit::TestCase
  def setup
    ensure_no_user_data("ruby")
  end
  def test_login_start
    load 'login-start.rb'

    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "background", y.job_name(1)
    assert_equal "<B>running</B>", y.status(1)
  end
  def teardown
    $iec.close if $iec
    ensure_no_user_data("ruby")
  end
end

class Lab3Dash2 < Test::Unit::TestCase
  def setup
    ensure_no_user_data("ruby")
  end
  def test_two_jobs
    load 'two-jobs.rb'

    y = get_results_table_array
    assert_equal 3, y.length
    assert_equal "job2", y.job_name(1)
    assert_equal "<B>running</B>", y.status(1)
    assert_equal "job1", y.job_name(2)
    assert_equal "paused", y.status(2)
  end
  def teardown
    $iec.close if $iec
    ensure_no_user_data("ruby")
  end
end
    
class ExtraTest < Test::Unit::TestCase
  def setup
    ensure_no_user_data("ruby")
  end
  def test_start_stop
    load 'start-stop.rb'

    y = get_results_table_array
    assert_equal 2, y.length
    assert_equal "foreground", y.job_name(1)
    assert_equal "", y.status(1)
  end
  def teardown
    $iec.close if $iec
    ensure_no_user_data("ruby")
  end
end

class ErikTest < Test::Unit::TestCase
  def setup
    ensure_no_user_data("Erik")
    @mockout = IOString.new ""
  end
  def test_erik
    $stdout = @mockout
    load 'erik.rb'
    $stdout = STDOUT
    # assert_no_match /FAIL/, @mockout 
    assert @mockout !~ /FAIL/
    assert_match /PASS.*PASS/, @mockout 
  end
  def teardown
    $stdout = STDOUT
    $iec.close if $iec
  end
end
