require 'util'

# Tests that do not seem to belong elsewhere.

class MiscTests < ProductTestCase
  def test_errors
    # We trust that the unit tests check whether the right exceptions are
    # thrown. Here, we wonder if any get to the client side.
    create_job_both_sides('hobby')
    assert_whine(:job_already_stopped, 'hobby') {
      @session.stop('hobby', Time.now)
    }
  end
end
