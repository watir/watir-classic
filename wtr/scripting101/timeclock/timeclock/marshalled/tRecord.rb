require 'timeclock/marshalled/Record'
require 'timeclock/marshalled/Job'


module Timeclock
  module Marshalled

    class RecordTests < Test::Unit::TestCase

      def test_equality
        job = Job.named('\n')
        equal_job = Job.named('\n')
        unequal_job = Job.named('\t')

        time = Time.now
        equal_time = time.dup
        unequal_time = time - 1

        assert_not_equal(Record.new(time, 0, job), 3)

        # Equality depends on Time, job, and duration

        assert_equal(Record.new(time, 5, job),
                     Record.new(equal_time, 5, equal_job))

        assert_not_equal(Record.new(time, 5, job),
                         Record.new(unequal_time, 5, equal_job))

        assert_not_equal(Record.new(time, 5, job),
                         Record.new(equal_time, 55, equal_job))

        assert_not_equal(Record.new(time, 5, job),
                         Record.new(equal_time, 5, unequal_job))

        # It does not depend on Persistent id.
        rec1 = Record.new(time, 5, job)
        rec2 = Record.new(equal_time, 5, equal_job)
        rec1.persistent_id = 1
        rec2.persistent_id = 2
        assert_equal(rec1, rec2)
      end

      def test_spaceship
        # Ordering depends only on start time.
        time = Time.now
        job = Job.named('job1')
        other = Job.named('other')
        
        assert_equal(-1, Record.new(time, 5, job) <=> Record.new(time+1, 0, job))
        assert_equal(0, Record.new(time, 5, job) <=> Record.new(time, 110, other))
        assert_equal(1, Record.new(time+1, 3, job) <=> Record.new(time, 1000, job))
                     
      end
    end  
  end
end
