require 'timeclock/marshalled/include-all'
require 'timeclock/util/ruby-extensions'
require 'timeclock/util/Time'

module Timeclock
  module Marshalled

    class ActiveRecordTests < Test::Unit::TestCase

      def setup
        @start_time = Time.set(Time.now)
        @job = Job.named('brian')
      end

      def teardown
        Time.use_system_time
      end

      def test_typical_sequence
        ar = ActiveRecord.start(@job, Time.now)
                assert_equal(true, ar.running?)
                assert_equal(false, ar.paused?)

        Time.advance(10.seconds)
        ar.pause(Time.now)
                assert_equal(false, ar.running?)
                assert_equal(true, ar.paused?)

        Time.advance(10.seconds)
        ar.restart(Time.now)
                assert_equal(true, ar.running?)
                assert_equal(false, ar.paused?)

        Time.advance(10.seconds)
        ar.stop(Time.now)
                assert_equal(false, ar.running?)
                assert_equal(false, ar.paused?)
        
        assert_equal(@start_time, ar.time_started)
        assert_equal(20.seconds, ar.time_accumulated)
      end

      def test_stopped_after_pause
        # Time spent pausing does not accumulate.

        ar = ActiveRecord.start(@job, Time.now)
        Time.advance(10.seconds)
        ar.pause(Time.now)
        Time.advance(10.minutes)
        ar.stop(Time.now)
                assert_equal(false, ar.running?)
                assert_equal(false, ar.paused?)

        
        assert_equal(@start_time, ar.time_started)
        assert_equal(10.seconds, ar.time_accumulated)
      end

      def test_equality
        # Use odd job names for variety
        Time.set(Time.now)  # redundant with set_up, but clearer.
        job = Job.named('\n')
        equal_job = Job.named('\n')
        unequal_job = Job.named('\t')

        time = Time.now
        equal_time = Time.now
        unequal_time = time + 1

        assert_equal(false, ActiveRecord.start(job, time) == 3)

        # Equality depends on job, state, start time, and duration

        ar1 = ActiveRecord.start(job, time)
        ar2 = ActiveRecord.start(equal_job, equal_time)
        assert_equal(ar1, ar2)

        ar1.pause(time)  # differs in state
        assert_not_equal(ar1, ar2)

        ar2.pause(unequal_time) # differs in time accumulated
        assert_not_equal(ar1, ar2)

        # differs in duration
        assert_not_equal(ActiveRecord.start(job, time),
                         ActiveRecord.start(job, time+1))

        # differs in job
        assert_not_equal(ActiveRecord.start(job, time),
                         ActiveRecord.start(unequal_job, time))
      end

      def test_restart_volunteer
        volunteer = Job.named('volunteer')
        volunteer_ar = ActiveRecord.start(volunteer, Time.now)
        volunteer_ar.potential_restart_volunteer = true
        volunteer_ar.pause(Time.now)

        shirker = Job.named('shirker')
        shirker_ar = ActiveRecord.start(shirker, Time.now)
        volunteer_ar.pause(Time.now)

        assert_equal(true, volunteer_ar.restart_volunteer?)
        assert_equal(false, shirker_ar.restart_volunteer?)

        # But a job should not volunteer if it's already doing something.
        volunteer_ar.restart(Time.now)
        assert_equal(false, volunteer_ar.restart_volunteer?)
      end

      def test_time_accumulated_tracks_elapsed_time
        job = Job.named('job')
        Time.set(Time.local(2002, 'jan', 1))
        ar = ActiveRecord.start(job, Time.now)
        assert_equal(0.seconds, ar.time_accumulated)
        Time.advance(1.second)         # one second
        assert_equal(1.second, ar.time_accumulated)
        Time.advance(1.second)         # two seconds
        assert_equal(2.seconds, ar.time_accumulated)
        Time.advance(1.second)         # three seconds
        ar.pause(Time.now)
        assert_equal(3.seconds, ar.time_accumulated)
        Time.advance(1.second)         # still three seconds
        assert_equal(3.seconds, ar.time_accumulated)

        ar.restart(Time.now)
        assert_equal(3.seconds, ar.time_accumulated)
        Time.advance(1.second)         # four seconds
        assert_equal(4.seconds, ar.time_accumulated)

        Time.advance(1.second)         # five seconds
        ar.stop(Time.now)
        assert_equal(5.seconds, ar.time_accumulated)
      end

      def test_time_accumulated_with_pauses_and_stops_in_the_past
        # What happens if you pause before the time shown on the system clock?

        job = Job.named('job')
        Time.set(Time.local(2002, 'jan', 1))
        ar = ActiveRecord.start(job, Time.local(2002, 'jan', 1))

        assert_equal(0.seconds, ar.time_accumulated)
        Time.advance(2.hours)
        assert_equal(2.hours, ar.time_accumulated)

        # Now pause the job in the past.
        ar.pause(Time.local(2002, 'jan', 1, 1))
        assert_equal(1.hour, ar.time_accumulated)

        # Restart at present time.
        ar.restart(Time.now)
        assert_equal(1.hour, ar.time_accumulated)
        Time.advance(5.hours)
        assert_equal(6.hours, ar.time_accumulated)

        # Now stop in the past - clock jumps back.
        ar.stop(Time.local(2002, 'jan', 1, 2))
        assert_equal(1.hour, ar.time_accumulated)
      end


      def test_time_accumulated_with_pauses_and_stops_in_the_future
        # What happens if you pause after the time shown on the system clock?

        job = Job.named('job')
        Time.set(Time.local(2002, 'mar', 20))
        ar = ActiveRecord.start(job, Time.local(2002, 'mar', 20))

        assert_equal(0.seconds, ar.time_accumulated)
        Time.advance(2.hours)           # hour 2.
        assert_equal(2.hours, ar.time_accumulated)

        # Now pause the job in the future.
        ar.pause(Time.local(2002, 'mar', 20, 3))
        assert_equal(3.hours, ar.time_accumulated)

        # Restart at present time - *before* previous pause. That
        # "double-billed" time is not noticed: there is no checking for
        # overlaps.
        ar.restart(Time.now)     # hour 2
        assert_equal(3.hours, ar.time_accumulated) 
        Time.advance(2.hours)           # hour 4 - one hour is counted twice.
        assert_equal(5.hours, ar.time_accumulated)

        # Now stop in the future.
        ar.stop(Time.local(2002, 'mar', 20, 5))
        assert_equal(6.hours, ar.time_accumulated)
      end

      def test_time_accumulated_with_start_time_in_the_past
        # As above, but when the local time started is different than
        # the argument to start
        job = Job.named('job')
        Time.set(Time.local(2002, 'feb', 21, 9))

        # Start an hour ago.
        ar = ActiveRecord.start(job, Time.local(2002, 'feb', 21, 8))
        # Look, we have an hour's work already.
        assert_equal(1.hour, ar.time_accumulated)

        Time.advance(1.minute)
        assert_equal(1.hour+1.minute, ar.time_accumulated)

        ar.pause(Time.now)
        assert_equal(1.hour+1.minute, ar.time_accumulated)

        Time.advance(59.minutes) # hour 10
        assert_equal(1.hour+1.minute, ar.time_accumulated)

        ar.restart(Time.local(2002, 'feb', 21, 9, 59))
        assert_equal(1.hour+2.minutes, ar.time_accumulated)
        Time.advance(1.minute)
        assert_equal(1.hour+3.minutes, ar.time_accumulated)

        ar.stop(Time.now)
        assert_equal(1.hour+3.minutes, ar.time_accumulated)
      end

      def test_time_accumulated_with_start_time_in_the_future
        # As above, but manipulate time in the future.
        job = Job.named('job')
        Time.set(Time.local(2002, 'feb', 21, 9))

        # Start an hour hence.
        ar = ActiveRecord.start(job, Time.local(2002, 'feb', 21, 10))
        # We have a negative hour's work.
        assert_equal(-1.hour, ar.time_accumulated)

        Time.advance(1.minute)
        assert_equal(-1.hour+1.minute, ar.time_accumulated)

        ar.pause(Time.now)
        assert_equal(-1.hour+1.minute, ar.time_accumulated)

        Time.set(Time.local(2002, 'feb', 21, 10))
        ar.restart(Time.now)

        # The negative time above is locked in at the time of pausing.
        assert_equal(-1.hour+1.minute, ar.time_accumulated)

        Time.advance(1.minute)
        assert_equal(-1.hour+2.minutes, ar.time_accumulated)

        # The original -59 minutes + 1 hour.
        ar.stop(Time.local(2002, 'feb', 21, 11))
        assert_equal(1.minute, ar.time_accumulated)
      end

    end
  end
end
