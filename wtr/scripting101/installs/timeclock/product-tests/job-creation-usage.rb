require 'util'

=begin

# You start the clock running by clicking on jobs or subjobs. Both are
# just named things that can record how much time was spent on
# them. Each can have an attribute. An important attribute for many
# would be "who gets billed for this time." But not all jobs will have
# that attribute. There's charity work. 

# Here's another sample use of jobs, subjobs, and attributes. Suppose
# you're a magazine editor for STQE. Miscellaneous work gets charged
# to STQE. Each article has its own subjob so that you can track the
# time spent on it separately. Each article also has an attribute that
# is the issue it goes in. So if you want to know the time spent on an
# issue, you can filter by attribute.

=end

class JobCreationUsage < ProductTestCase

  def test_job_creation

    # Create an ordinary job
    email = Job.named('misc_email')
    @session.accept_job(email)

    timeclock = Job.named('timeclock')
    @session.accept_job(timeclock)

    # Jobs can have subjobs
    stqe = Job.named('stqe')
    @session.accept_job(stqe)
    subjob = Job.named_with_parent('faught scripting', stqe)
    @session.accept_job(subjob)
    
    # Of course, you can add more than one subjob to a job.
    subjob = Job.named_with_parent('pettichord - testers think diff.', stqe)
    @session.accept_job(subjob)

    # And you can always revisit an earlier job and add a subjob.
    subjob = Job.named_with_parent('iteration 1', timeclock)
    @session.accept_job(subjob)

    #### Check that everything is as expected.
    jobs = @session.jobs
    assert_equal(3, jobs.size)
    
    email = jobs['misc_email']
    assert email
    
    stqe = jobs['stqe']
    assert stqe
    assert stqe.subjobs['faught scripting']
    assert stqe.subjobs['pettichord - testers think diff.']

    timeclock = jobs['timeclock']
    assert timeclock
    assert timeclock.subjobs['iteration 1']
  end

  def test_attributes
    stqe = Job.named('stqe')
    @session.accept_job(stqe)
    
    sixt = Job.named_with_parent('sixt - adaptive', stqe)
    sixt.attributes['issue'] = 'v4n5'
    sixt.attributes['deadline'] = 'standard'
    @session.accept_job(sixt)

    # Oops. Forgot one. Attributes can be added after the fact.
    sixt.attributes['topic'] = 'testing'
    @session.accept_job(sixt)

    #### Check that everything is as expected.
    assert_equal(stqe, @session.jobs['stqe'])
    assert_equal(sixt, @session.jobs['stqe'].subjobs['sixt - adaptive'])
    assert_equal(1, @session.jobs.size)
    #### End checks


    # Don't like those attributes. Let's start over.
    sixt.attributes.replace({ 'volume' => '4', 'number'=>'5' })
    @session.accept_job(sixt)

    #### Check that everything is as expected.
    assert_equal(stqe, @session.jobs['stqe'])
    assert_equal(sixt, @session.jobs['stqe'].subjobs['sixt - adaptive'])
    assert_equal(1, @session.jobs.size)
    #### End checks
  end
end  

