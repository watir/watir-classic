require 'util'

class DailyUsage < ProductTestCase

  def setup
    super
    @misc = create_job_both_sides('misc', :background)
    @stqe = create_job_both_sides('stqe')
    @timeclock = create_job_both_sides('timeclock')
  end

  def test_a_normal_day
    # The setting of time is only so that the records are created in
    # a guaranteed order.
    start_background_job
                                assert_states([@misc], [])
                                stqe_start_time = @now
    start 'stqe'
                                assert_states([@stqe], [@misc])
                                timeclock_start_time = @now
    start 'timeclock'
                                assert_states([@timeclock], [@misc, @stqe])


    pause_without_resumption
                                assert_states([], [@timeclock, @misc, @stqe])
    start 'stqe'
                                assert_states([@stqe], [@misc, @timeclock])
    pause
                                assert_states([@misc], [@timeclock, @stqe])
    start 'stqe'
                                assert_states([@stqe], [@misc, @timeclock])
    stop_all
                                assert_states([], [])
    
    records = @session.records
    assert_equal(3, records.length)
    assert_equal(FinishedRecord.new(@test_start_time, 2.minutes, @misc),
                 records[0])
    assert_equal(FinishedRecord.new(stqe_start_time, 3.minutes, @stqe),
                 records[1])
    assert_equal(FinishedRecord.new(timeclock_start_time, 1.minute, @timeclock),
                 records[2])

    # Let's start another, uneventful, day.
                                next_day=@now
    start_background_job
                                assert_states([@misc], [])
    pause
                                assert_states([], [@misc])
    stop_all
                                assert_states([], [])

    records = @session.records
    assert_equal(4, records.length)
    assert_equal(FinishedRecord.new(next_day, 1.minute, @misc),
                 records[3])
  end

  def test_switching_background_job
    # Start the day...
    start_background_job
                                assert_states([@misc], [])

    # Do a little work... 
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause
                                assert_states([@misc], [@stqe])
    start 'timeclock'
                                assert_states([@timeclock], [@stqe, @misc])
    
    # Tomorrow, I want "conference" to be the background job.
    @conference = create_job_both_sides('conference', :background)
    # 'misc' remains the background job.
    start 'stqe'
                                assert_states([@stqe], [@timeclock, @misc])
    pause
                                assert_states([@misc], [@timeclock, @stqe])

    # We can, however, start 'conference' as a normal job.
    start 'conference'
                                assert_states([@conference], [@misc, @timeclock, @stqe])
    # That is, 'misc' remains the background
    pause
                                assert_states([@misc], [@conference, @timeclock, @stqe])
    start 'stqe'
                                assert_states([@stqe], [@misc, @conference, @timeclock])
    pause
                                assert_states([@misc], [@stqe, @conference, @timeclock])
    
    stop_all
                                assert_states([], [])

    # The next day, 'conference' acts as the background.
    start_background_job
                                assert_states([@conference], [])

    start 'stqe'
                                assert_states([@stqe], [@conference])
    pause
                                assert_states([@conference], [@stqe])
    stop_all
                                assert_states([], [])
  end


  def test_no_clean_start_background_job
    # Start the day, but don't use start_background_job
    start 'stqe'
                                assert_states([@stqe], [])
    stop 'stqe'
                                assert_states([], [])

    # Now start the background job explicitly.
    start 'misc'
                                assert_states([@misc], [])

    # But that still won't cause it to volunteer to restart
    start 'stqe'
                                assert_states([@stqe], [@misc])
    stop 'stqe'
                                assert_states([], [@misc])

    # You must stop both jobs and start the day afresh.
    stop_all
                                assert_states([], [])
    start_background_job
                                assert_states([@misc], [])

    # Now it works as expected.
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause
                                assert_states([@misc], [@stqe])
    stop 'stqe'
                                assert_states([@misc], [])
    pause   # the background job
                                assert_states([], [@misc])

    # Now what if you /stop/ the paused job? It at first seemed wrong for
    # default to start, but then Dawn decided it made sense: you've
    # gone to lunch, then you've come back, and done a little tidying
    # before starting an explicit job.
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause_without_resumption
                                assert_states([], [@stqe, @misc])
    stop 'stqe'
                                assert_states([@misc], [])
    stop_all
                                assert_states([], [])
    stop_all # stop it twice, by accident
                                assert_states([], [])
  end

  def test_stop_background_job_in_the_middle_of_the_day
    start_background_job
                                assert_states([@misc], [])
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause
                                assert_states([@misc], [@stqe])

    # Once you stop the background job, no other job resumes when
    # one is paused.
    stop 'misc'
                                assert_states([], [@stqe])
    start 'stqe'
                                assert_states([@stqe], [])
    pause
                                assert_states([], [@stqe])

    # This is true even if you start the background job again in
    # the normal way 
    start 'misc'
                                assert_states([@misc], [@stqe])
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause
                                assert_states([], [@stqe, @misc])

    # You have to stop the day and restart it. That's kind of annoying.
    stop_all
                                assert_states([], [])
    start_background_job
                                assert_states([@misc], [])
    start 'stqe'
                                assert_states([@stqe], [@misc])
    pause
                                assert_states([@misc], [@stqe])

    stop_all
                                assert_states([], [])
  end
    
end  

