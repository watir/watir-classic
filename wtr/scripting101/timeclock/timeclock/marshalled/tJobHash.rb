require 'timeclock/marshalled/JobHash'


module Timeclock
  module Marshalled

    class JobHashTests < Test::Unit::TestCase

      def test_background_job
        jobs = JobHash.new
        assert_equal(nil, jobs.background_job)


        job = Job.named('a job')
        jobs[job.name] = job
        assert_equal(nil, jobs.background_job)

        job.make_background
        assert_equal(job, jobs.background_job)
      end

      def test_install_and_forget_child
        jobs = JobHash.new

        job = Job.named('a job')
        jobs[job.name] = job

        subjob = Job.named_with_parent('subjob', job)

        jobs.install_child(subjob)
        assert_equal(subjob, jobs['a job'].subjobs['subjob'])
        assert_equal(subjob, jobs.delete_child(subjob))
        assert_equal(nil, jobs['a job'].subjobs['subjob'])

        # Above works even when child has a different parent with the same
        # name (as often happens when jobs come across the wire).

        alias_job = Job.named('a job')
        subjob = Job.named_with_parent('subjob', alias_job)

        jobs.install_child(subjob)
        assert_equal(subjob, jobs['a job'].subjobs['subjob'])
        assert_equal(subjob, jobs.delete_child(subjob))
        assert_equal(nil, jobs['a job'].subjobs['subjob'])
      end
    end  
  end
end
