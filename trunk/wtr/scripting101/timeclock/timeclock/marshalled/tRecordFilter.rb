require 'timeclock/marshalled/include-all'

module Timeclock
  module Marshalled
    # These tests are shallow because most of the work is done by
    # other tests. They're to smooth development, so that
    # I don't have to figure out much when I first run the other
    # tests.

    class RecordFilterTests < Test::Unit::TestCase
      def test_run
        job = Job.named('a random job')
        records = [FinishedRecord.new(Time.now, 0, job)]
        filter = RecordFilter.new { | record | true }
        filtered_records = filter.run(records)
        assert_equal(records, filtered_records)

        filter = RecordFilter.new { | record | record.job.name =~ /random/ }
        filtered_records = filter.run(records)
        assert_equal(records, filtered_records)
      end


      def test_job_record_filter_run
        job = Job.named('a')
        subjob = Job.named_with_parent('sub', job)
        job_record = FinishedRecord.new(Time.now, 0, job)
        subjob_record = FinishedRecord.new(Time.now, 0, subjob)

        unmatching = Job.named('unmatching parent')
        unmatching_record = FinishedRecord.new(Time.now, 0, unmatching)
        unmatching_subjob = Job.named_with_parent('sub', unmatching)
        unmatching_subjob_record = FinishedRecord.new(Time.now, 0, unmatching_subjob)

        filter = RecordFilter.by_job_full_name('a')
        assert_equal([job_record, subjob_record],
                     filter.run([job_record, subjob_record,
                                 unmatching_record, unmatching_subjob_record]))

        filter = RecordFilter.by_job_full_name('a/sub')
        # Just for laughs, have two copies of subjob.
        assert_equal([subjob_record, subjob_record.dup],
                     filter.run([subjob_record, job_record, subjob_record.dup,
                                unmatching_record, unmatching_subjob_record]))

        # Subjobs only match if the job matches
        filter = RecordFilter.by_job_full_name('sub')
        assert_equal([], filter.run([subjob_record]))
      end

      def test_time_interval
        job = Job.named('dated')

        # We'll be using the filter to find all records in October.

        # The first second of October
        beginning_month = FinishedRecord.new(Time.local(2002, "oct", 1, 0, 0, 0),
                                             3.seconds, job)

        # A job that starts before the October boundary but ends after
        # it isn't in October. What matters is when a job starts,
        # not when it ends.
        before_month = FinishedRecord.new(Time.local(2002, "sep", 30, 23, 59, 59),
                                          2.hours, job)

        # This time, which extends over a boundary, is counted as in October.
        ending_month = FinishedRecord.new(Time.local(2002, "oct", 31, 23, 59, 59),
                                          2.minutes, job)

        # The first second of November.
        after_end = FinishedRecord.new(Time.local(2002, "nov", 1), 3.hours, job)

        interesting_times = [before_month, beginning_month, ending_month, after_end]

        # The definition of "being in October":
        assert_october_starts = proc { | records, count |
          assert_equal(count, records.size)
          records.each { | rec |
            assert_equal(10, rec.time_started.month)
          }
        }

        # Since the filter is inclusive, to get an entire month's
        # jobs, you make the end time be the last second of the month.

        filter =
          RecordFilter.by_time_interval(
             Time.local(2002, "oct", 1),
             Time.local(2002, "oct", 31, 23, 59, 59))
        records = filter.run(interesting_times)
        assert_october_starts[records, 2]
        # try it with by_month_to_time
        filter =
          RecordFilter.by_month_to_time(Time.local(2002, "oct", 31, 23, 59, 59))
        records = filter.run(interesting_times)
        assert_october_starts[records, 2]

        # Also check that it works with end times in middle of month.
        filter =
          RecordFilter.by_time_interval(
             Time.local(2002, "oct", 1),
             Time.local(2002, "oct", 31, 23, 59, 58))
        new_records = filter.run(interesting_times)
        assert_october_starts[new_records, 1]
      end
    end
  end
end

