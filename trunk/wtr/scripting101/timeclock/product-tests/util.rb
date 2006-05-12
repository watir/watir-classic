require 'timeclock/util/misc'
require 'timeclock/util/test-util'

require 'timeclock/marshalled/include-all'

require 'timeclock/client/RecordStringifier'
require 'ServerManager'
include Timeclock::Client

class ProductTestCase < Test::Unit::TestCase

  PRODUCT_TEST_USER = "product tests"
    
  def setup
    super
    @now = @test_start_time = Time.local('2002', 2, 19)
    ServerManager.connect
    ServerManager.delete_user PRODUCT_TEST_USER
    @session = ServerManager.session_for(PRODUCT_TEST_USER)
  end

  def teardown
    super
    @session.forget_everything
    ServerManager.connect
    ServerManager.deactivate_user_session(PRODUCT_TEST_USER)
  end

  def create_job_both_sides(name, background = false)
    @session.accept_job(Job.named(name))
    @session.background(name) if background
    @session.find_job_named(name)
  end

  def create_subjob_both_sides(name, parent)
    j = Job.named_with_parent(name, parent)
    @session.accept_job(j)
    j
  end

  def assert_states(expected_started, expected_paused)
    assert(expected_started.length <= 1,
           "Test error: can be at most one started job.")

    ars = @session.active_records
    assert(expected_started.length + expected_paused.length, ars.length)

    assert_has_state = proc { | state, jobs | 
      jobs.each { | j |
        assert_equal(true, ars[j].send(state))
      }
    }

    assert_has_state.call(:running?, expected_started)
    assert_has_state.call(:paused?, expected_paused)
  end

  # Methods that do things and increment time. 
  def increment_time
    @now += 1.minute
  end

  def start(job)
    @session.start(job, @now)
    increment_time
  end

  def stop(job)
    @session.stop(job, @now)
    increment_time
  end

  def pause
    @session.pause(@now)
    increment_time
  end

  def start_background_job
    @session.start_background_job(@now)
    increment_time
  end

  def pause_without_resumption
    @session.pause_without_resumption(@now)
    increment_time
  end

  def stop_all
    @session.stop_all(@now)
    increment_time
  end

  def test_nothing
    # Test::Unit complains if a TestCase doesn't have a test in it. So
    # if your abstractish base class gets loaded up by accident, you lose.
  end
end


