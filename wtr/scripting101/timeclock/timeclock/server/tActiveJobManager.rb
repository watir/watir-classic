require 'timeclock/server/ActiveJobManager'
require 'timeclock/marshalled/ActiveRecord'
require 'timeclock/util/Steps'

module Timeclock
  module Server
    # These tests are shallow because most of the work is done by
    # the product-level tests. They're to smooth development, so that
    # I don't have to figure out much when I first run the product
    # tests.

    class ActiveJobManagerTests < Test::Unit::TestCase

      include Steps

      def teardown
        clear_change_log
      end

      def setup
        clear_change_log
      end

      def test_basic
        job_start_time = current_time = Time.now
        job = Job.named('-')
        other_job = Job.named('-2-')

        manager = ActiveJobManager.new(RecordList.new)
        assert_equal(false, manager.any_active?)
        assert_equal(true, manager.stopped?(job))
        assert_equal(false, manager.running?(job))
        assert_equal(false, manager.paused?(job))
                      
        manager.start(job, job_start_time)
        other_job_start_time = current_time = job_start_time + 10.seconds
        manager.start(other_job, other_job_start_time)     # job has 10 seconds

        assert_equal(true, manager.any_active?)
        ars = manager.active_records
        assert_equal(2, ars.length)
        assert_equal(true, manager.paused?(job))
        assert_equal(true, manager.running?(other_job))
        assert_equal(false, manager.stopped?(job))
        assert_equal(false, manager.stopped?(other_job))

        current_time += 10.seconds
        manager.pause(current_time)           # job has 10, other has 10
        assert_equal(true, manager.any_active?)
        ars = manager.active_records
        assert_equal(2, ars.length)
        assert_equal(true, manager.paused?(job))
        assert_equal(true, manager.paused?(other_job))
        assert_equal(false, manager.stopped?(job))
        assert_equal(false, manager.stopped?(other_job))

        current_time += 10.seconds
        manager.start(job, current_time)      # job has 10, other has 10
        assert_equal(true, manager.any_active?)
        ars = manager.active_records
        assert_equal(2, ars.length)
        assert_equal(true, manager.running?(job))
        assert_equal(true, manager.paused?(other_job))
        assert_equal(false, manager.stopped?(job))
        assert_equal(false, manager.stopped?(other_job))

        current_time += 10.seconds               # job has 20, other has 10
        record = manager.stop(other_job, Time.now)
        assert_equal(true, manager.any_active?)
        assert_equal(other_job_start_time, record.time_started)
        assert_equal(10.seconds, record.time_accumulated)
        assert_equal(other_job, record.job)
        ars = manager.active_records
        assert_equal(1, ars.length)
        assert_equal(true, manager.stopped?(other_job))
        assert_equal(true, manager.running?(job))
        assert_equal(false, manager.paused?(job))
        assert_equal(false, manager.stopped?(job))

        current_time += 10.seconds              # job has 30, other has 10
        record = manager.stop(job, current_time)
        assert_equal(false, manager.any_active?)
        assert_equal(job_start_time, record.time_started)
        assert_equal(30.seconds, record.time_accumulated)
        assert_equal(job, record.job)
        assert_equal(0, manager.active_records.length)
        assert_equal(true, manager.stopped?(job))
        assert_equal(true, manager.stopped?(other_job))
      end

      def test_restart_volunteer
        manager = ActiveJobManager.new(RecordList.new)

        # Nothing special when there's no restart-volunteer job.
        shirker = Job.named('shirker')
        manager.start(shirker, Time.now)
        assert_equal(nil, manager.active_background)
        assert_equal(nil, manager.restart_volunteer)

        manager.pause(Time.now)
        assert_equal(true, manager.paused?(shirker))
        
        # Create a volunteer. 
        volunteer = Job.named('volunteer')
        manager.start(volunteer, Time.now, true)
        assert_equal(volunteer, manager.active_background.job)
        assert_equal(nil, manager.restart_volunteer) # it's running.

        # A restart-volunteer job won't volunteer if it's the one being paused.
        manager.pause(Time.now)
        assert_equal(true, manager.paused?(shirker))
        assert_equal(true, manager.paused?(volunteer))

        # It will volunteer if it's already paused (normal case)
        manager.start(shirker, Time.now)
        assert_equal(volunteer, manager.restart_volunteer.job)
        manager.pause(Time.now)
        assert_equal(true, manager.paused?(shirker))
        assert_equal(true, manager.running?(volunteer))
        assert_equal(nil, manager.restart_volunteer)

        # Restart-volunteer jobs volunteer when jobs stop.
        manager.start(shirker, Time.now)
        assert_equal(volunteer, manager.restart_volunteer.job)
        manager.stop(shirker, Time.now)
        assert_equal(true, manager.stopped?(shirker))
        assert_equal(true, manager.running?(volunteer))
        assert_equal(nil, manager.restart_volunteer)
      end
        
    end
  end
end
