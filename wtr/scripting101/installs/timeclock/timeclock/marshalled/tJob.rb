require 'timeclock/marshalled/Job'

module Timeclock
  module Marshalled

    # Caller responsibility for types of arguments throughout.

    class JobTests < Test::Unit::TestCase
      def test_creation
        job = Job.named('job name')
        assert_equal('job name', job.name)
        assert_equal(nil, job.parent)  # should be no need for Null Object.
        assert_equal({}, job.subjobs)
        assert_equal({}, job.attributes)
      end


      def basic_eXXl(message)  # test both eql and ==
        assert_equal(false, Job.named('A job').send(message, 5))

        # equality depends on names
        assert_equal(false, Job.named('something').send(message, Job.named('else')))
        orig = Job.named('fred')
        other = Job.named('fred')
        assert_equal(true, orig.send(message, other))

        # It also depends on the existence and names of parents.
        first_job = Job.named('job 1')
        second_job = Job.named('job 2')
        first_subjob = Job.named_with_parent('subjob', first_job)
        second_subjob = Job.named_with_parent('subjob', second_job)
        assert_equal(false, first_subjob.send(message, second_subjob))

        parent_named_subjob = Job.named('subjob')
        assert_equal(false, first_subjob.send(message, parent_named_subjob))
        assert_equal(false, parent_named_subjob.send(message, second_subjob))

        # And, of course, a job is equal to itself (just checking...)
        assert_equal(true, orig.send(message, orig))
        assert_equal(true, first_subjob.send(message, first_subjob))
      end

      def test_basic_equality
        basic_eXXl("==")
      end

      def test_basic_eql?
        basic_eXXl("eql?")
      end

      def test_additional_equality  # how == differs from eql?
        orig = Job.named('fred')
        other = Job.named('fred')

        # == also depends on attributes
        orig.attributes['1']="1"
        assert_not_equal(orig, other)
        other.attributes['1']="1"
        assert_equal(orig, other)

        # It also depends on subjobs
        orig_subjob = Job.named_with_parent('subjob', orig)
        assert_not_equal(orig, other)
        other_subjob = Job.named_with_parent('subjob', other)
        assert_equal(orig, other)

        # and their attributes
        orig_subjob.attributes['hi'] = 'there'
        assert_not_equal(orig, other)
      end

      def test_hash   # a.eql?b => a.hash==b.hash
        plain_job = Job.named("job")
        complex_job = Job.named("job")
        assert_equal(plain_job.hash, complex_job.hash)
        
        # Subjobs do not affect hash (or eql?)
        subjob = Job.named_with_parent("subjob", complex_job)
        assert_equal(plain_job.hash, complex_job.hash)

        # Ditto for attributes.
        complex_job.attributes['1'] = 1
        assert_equal(plain_job.hash, complex_job.hash)
      end

      todo 'should job comparisons be based on name or full_name?'

      def test_spaceship_operator
        assert(-1, Job.named('a') <=> Job.named('aa'))
        assert(0, Job.named('x') <=> Job.named('x'))
        assert(1, Job.named('Z') <=> Job.named('X'))

        # sensitive to case.
        assert(1, Job.named('a') <=> Job.named('A'))
      end

      def test_subjobs_have_parents
        job = Job.named('parent')
        job.attributes['hi'] = 'there'  # check that attributes aren't inherited.
        subjob = Job.named_with_parent('child', job)
        assert_equal(job, subjob.parent)
        assert_equal({}, subjob.attributes) # by the way, attributes empty.

        another_subjob = Job.named_with_parent('another', job)
        assert_equal(job, another_subjob.parent)
        assert_equal({}, another_subjob.attributes)

        assert_equal(2, job.subjobs.length)
        assert_equal("child", job.subjobs["child"].name)
        assert_equal("another", job.subjobs["another"].name)

      end

      def test_full_name
        job = Job.named('parent')
        assert_equal("parent", job.full_name)
        assert_equal("parent", job.name)
        subjob = Job.named_with_parent('subjob', job)
        assert_equal('parent/subjob', subjob.full_name)
        assert_equal('subjob', subjob.name)
      end

      def test_full_name_parsing
        jobname, subjobname = Job.parse_full_name("a")
        assert_equal("a", jobname)
        assert_equal(nil, subjobname)

        jobname, subjobname = Job.parse_full_name("dawn/brian")
        assert_equal("dawn", jobname)
        assert_equal("brian", subjobname)
      end
    end  
  end
end
