require 'timeclock/marshalled/FinishedRecord'
require 'timeclock/marshalled/Job'
require 'timeclock/marshalled/RecordList'


module Timeclock
  module Marshalled

    class RecordListTests < Test::Unit::TestCase

      def setup
        @job = Job.named('jobs')
        @other_job = Job.named('other job')
      end

      def test_additions
        @records = RecordList.new

        zero = FinishedRecord.new(Time.local(2002, 'jan', 1), 1.minute, @job)
        one = FinishedRecord.new(Time.local(2002, 'feb', 1), 10.minutes, @other_job)
        two = FinishedRecord.new(Time.local(2002, 'may', 1), 100.minutes, @job)

        @records.add(zero).add(one).add(two)
        assert_equal(zero, @records[0])
        assert_equal(one, @records[1])
        assert_equal(two, @records[2])
        assert_equal(0, zero.persistent_id)
        assert_equal(1, one.persistent_id)
        assert_equal(2, two.persistent_id)


        # Now check that additions are sorted in.
        new_two = FinishedRecord.new(two.time_started - 1, 30.minutes, @other_job)
        @records.add(new_two)
        assert_equal(zero, @records[0])
        assert_equal(one, @records[1])
        assert_equal(new_two, @records[2])
        assert_equal(two, @records[3])
        assert_equal(0, zero.persistent_id)
        assert_equal(1, one.persistent_id)
        assert_equal(3, new_two.persistent_id)
        assert_equal(2, two.persistent_id)

        # Persistent id's are not changed on re-insertion.
        @records.delete_at(1)
        assert_equal(zero, @records[0])
        assert_equal(new_two, @records[1])
        assert_equal(two, @records[2])

        assert_equal(0, zero.persistent_id)
        assert_equal(3, new_two.persistent_id)
        assert_equal(2, two.persistent_id)

        @records.add(one)
        assert_equal(zero, @records[0])
        assert_equal(one, @records[1])
        assert_equal(new_two, @records[2])
        assert_equal(two, @records[3])
        assert_equal(0, zero.persistent_id)
        assert_equal(1, one.persistent_id)
        assert_equal(3, new_two.persistent_id)
        assert_equal(2, two.persistent_id)
      end

      def test_record_with_id
        @records = RecordList.new

        rec0 = FinishedRecord.new(Time.now, 30.minutes, @other_job)
        rec1 = FinishedRecord.new(Time.local(2000, 'jan', 1), 30.minutes, @other_job)
        @records.add(rec0)
        @records.add(rec1)
        # Check that sorting order is as expected - rec1 sorts first
        assert_equal(rec1, @records[0])
        assert_equal(rec0, @records[1])

        assert_equal(rec0, @records.record_with_id(0))
        assert_equal(rec1, @records.record_with_id(1))

        # Nil means not found
        assert_equal(nil, @records.record_with_id(2))
      end

    end  
  end
end
