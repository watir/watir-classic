require 'timeclock-web-services'
require 'test/unit'

class TestStart < Test::Unit::TestCase

  # Utilities
  def start_session_with_star_job
    session = start_session
    job = Job.named('star')
    session.accept_job(job)
    assert_equal(0, session.records.length)
    session
  end

  # Tests
  def test_starting_job_creates_record
    session = start_session_with_star_job
    session.start('star', Time.now)
    assert_equal(1, session.records.length)
  end

  def test_starting_job_twice_is_an_error
    session = start_session_with_star_job
    # Now start the job the first time.
    session.start('star', Time.now)
    assert_equal(1, session.records.length)

    # Second starts are user errors.
    assert_raises(TimeclockError) { 
      session.start('star', Time.now)
    }
    assert_equal(1, session.records.length)
  end


end
