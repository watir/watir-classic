require 'timeclock/marshalled/include-all'
require 'timeclock/client/RecordStringifier'

module Timeclock
  module Client

    # Appears to be a bug on NT where Time.local doesn't take daylight
    # savings time into account, whereas Time.now does. The dates below
    # deftly avoid that bug.

    class RecordStringifierTests < Test::Unit::TestCase

      def setup
        @job = Job.named('job')
        @subjob = Job.named_with_parent('a mere child', @job)
      end

      def teardown
        Time.use_system_time
      end
      
      def test_with_single_digit_numbers
        # Note we use a job without subjob

        time_started = Time.local(2001, 01, 3, 1, 0)
        maker = RecordStringifier.new(FinishedRecord.new(time_started,
                                                 1.hour + 1.minute,
                                                 @job))

        assert_equal("02001/01/03  1:00 AM", maker.start_date_time)
        assert_equal(" 1.02 hours", maker.cumulative_hours)
        assert_equal("job", maker.job)
        assert_equal("", maker.subjob)
        assert_equal("job", maker.full_job_name)
      end

      def test_with_two_digit_numbers
        # Here we use a subjob

        time_started = Time.local(2001, 11, 12, 10, 0)
        maker = RecordStringifier.new(FinishedRecord.new(time_started,
                                                 13.hours + 6.minutes,
                                                 @subjob))

        assert_equal("02001/11/12 10:00 AM", maker.start_date_time)
        assert_equal("13.10 hours", maker.cumulative_hours)
        assert_equal("job", maker.job)
        assert_equal("a mere child", maker.subjob)
        assert_equal("job/a mere child", maker.full_job_name)
      end

      def test_summary
        job = Job.named('j')
        subjob = Job.named_with_parent('k', job)

        ##  Dates
        # no zero-filling
        r = FinishedRecord.new(Time.local(2003, 12, 14, 10, 31), 1.hour, job)
        assert_equal(" 1.00 hour  from 02003/12/14 10:31 AM on j",
               RecordStringifier.new(r).summary)

        # zero-filling - note padding on "1:05".
        r = FinishedRecord.new(Time.local(2003, 1, 2, 1, 5), 1.hour, job)
        assert_equal(" 1.00 hour  from 02003/01/02  1:05 AM on j",
               RecordStringifier.new(r).summary)

        # PM
        r = FinishedRecord.new(Time.local(2003, 1, 2, 13, 5), 1.hour, job)
        assert_equal(" 1.00 hour  from 02003/01/02  1:05 PM on j",
               RecordStringifier.new(r).summary)

        ## Hours
        r = FinishedRecord.new(Time.local(2003, 1, 2, 1, 5), 2.hour+6.minutes, job)
        assert_equal(" 2.10 hours from 02003/01/02  1:05 AM on j",
               RecordStringifier.new(r).summary)
        
        r = FinishedRecord.new(Time.local(2003, 1, 2, 1, 5), 15.minutes, job)
        assert_equal(" 0.25 hours from 02003/01/02  1:05 AM on j",
               RecordStringifier.new(r).summary)
        
        r = FinishedRecord.new(Time.local(2003, 1, 2, 1, 5), 15.hours, job)
        assert_equal("15.00 hours from 02003/01/02  1:05 AM on j",
               RecordStringifier.new(r).summary)

        ## Jobs - printed with full names.
        r = FinishedRecord.new(Time.local(2003, 1, 2, 1, 5), 15.hours, subjob)
        assert_equal("15.00 hours from 02003/01/02  1:05 AM on j/k",
               RecordStringifier.new(r).summary)

      end

      def test_active_record
        job = Job.named('hi')
        Time.set(Time.local(2030, 9, 3))
        ar = ActiveRecord.start(job, Time.local(2030, 9, 3))
        # Note that the print doesn't contain the day (in either assert)
        # because that day is "today".
        assert_equal(" 0.00 hours from 12:00 AM on hi (running)",
                     RecordStringifier.new(ar).summary)
        ar.pause(Time.local(2030, 9, 4))
        assert_equal("24.00 hours from 12:00 AM on hi (paused)",
                     RecordStringifier.new(ar).summary)
      end
      
    end
  end
end
