require 'util'

class StartupShutdownUsageTests < ProductTestCase
  def setup
    super
    @hobby = create_job_both_sides('hobby')
    @timeclock = create_subjob_both_sides('timeclock', @hobby)
  end

  def test_normal_single_user_use
    original_jobs = @session.jobs
    test_start = Time.now
    
    @session.start(@timeclock, test_start)
    @session.stop(@timeclock, test_start + 1.second)
    first_records = @session.records
    assert_equal(1, first_records.length)
    assert_equal(@timeclock, first_records[0].job)
    assert_equal(1, first_records[0].time_accumulated)
    assert_equal(test_start, first_records[0].time_started)
    ServerManager.stop_server

    ServerManager.connect
    @session = ServerManager.session_for(PRODUCT_TEST_USER)
    assert_equal(original_jobs, @session.jobs)

    second_records = @session.records
    assert_equal(first_records, second_records)

    second_start = Time.now
    @session.start(@hobby, second_start)
    @session.pause(second_start+10.seconds)
    @session.stop(@hobby, second_start + 1.hour)
    ServerManager.stop_server
    
    ServerManager.connect
    @session = ServerManager.session_for(PRODUCT_TEST_USER)
    assert_equal(original_jobs, @session.jobs)
    third_records = @session.records
    assert_equal(first_records[0], third_records[0])
    assert_equal(@hobby, third_records[1].job)
    assert_equal(10.seconds, third_records[1].time_accumulated)
    assert_equal(second_start, third_records[1].time_started)
  end

=begin

the following test is broken. original test stopped making sense when
responsibilities were reassigned. however, it still passed (but for
wrong reasons) on Mac. but it breaks on windows.

=end

  def NOT_test_shutdown_while_timing
    # What happens if you exit while some job is running or
    # paused?
    first_start_time = Time.now
    @session.start(@hobby, first_start_time)     # 1
    sleep 1
    second_start_time = Time.now
    @session.start(@timeclock, second_start_time) # 2

    original_ars = @session.active_records
    ServerManager.stop_server
    sleep 1  # Make sure some time elapses.
    ServerManager.connect
    @session = ServerManager.session_for(PRODUCT_TEST_USER)
    ars = @session.active_records
    assert_equal(original_ars[@hobby], ars[@hobby])
    assert_equal(original_ars[@timeclock].time_started,
                 ars[@timeclock].time_started)
    assert_equal(original_ars[@timeclock].job,
                 ars[@timeclock].job)
    assert(original_ars[@timeclock].time_accumulated < 
           ars[@timeclock].time_accumulated)  # still running
    assert_equal(2, ars.length)
    assert_equal(2, @session.records.length)  # the two active jobs

    stop_time = Time.now
    @session.stop(@hobby, stop_time)
    @session.stop(@timeclock, stop_time)

    records = @session.records

    assert_equal(2, records.length)
    assert_equal(@hobby, records[0].job)
    assert_equal(first_start_time, records[0].time_started)
    # Note: rounding to integers to avoid failing on small arithmetic errors. 
    assert_equal((second_start_time - first_start_time).to_i,
                 records[0].time_accumulated.to_i)
    
    assert_equal(@timeclock, records[1].job)
    assert_equal(second_start_time, records[1].time_started)
    assert_equal((stop_time - second_start_time).to_i,
                 records[1].time_accumulated.to_i)

    # Check that new records are still added to end.
    @session.start(@hobby, stop_time)
    @session.stop(@hobby, stop_time)
    new_records = @session.records
    assert_equal(3, new_records.length)
    assert_equal(records[0], new_records[0])
    assert_equal(records[1], new_records[1])
  end

  # SIGINT is ^C to command-line version.
  def test_survives_sigint
    check_survives('SIGINT')
  end

  # SIGHUP is sent on logout, system shutdown.
  def test_survives_sighup
    check_survives('SIGHUP')
  end

  todo 'Periodically check that all state-changing commands spill to disk.'
  
  # It might be better to systematically check the background, rather than
  # just that some single thing implied by an action before a crash survives
  # the crash. Do that if the way saving is done becomes more complicated
  # than just saving everything after every state change.
  def check_survives(sig)
    return if Config::CONFIG['target_vendor'] == 'pc' # otherwise dumps core
                                                               # ACCEPT_JOB
    background = create_job_both_sides('background')
    bounce_server(sig)
    assert_records()
    # Note that timeclock doesn't appear in jobs list because it's a subjob.
    assert_jobs('hobby', 'background')

                                                               # BACKGROUND
    background = @session.background('background')
    bounce_server(sig)
    assert_jobs('hobby', 'background')
    assert(@session.jobs['background'].is_background?)

                                                       # START_BACKGROUND_JOB
    @session.start_background_job(Time.now)
    bounce_server(sig)
    assert_records([ActiveRecord, background, 'running'])
    assert_jobs('hobby', 'background')


                                                                # START
    @session.start(@timeclock, Time.now)
    bounce_server(sig)
    assert_records([ActiveRecord, background, 'paused'],
                   [ActiveRecord, @timeclock, 'running'])
    assert_jobs('hobby', 'background')

                                                               # PAUSE
    @session.pause(Time.now)
    bounce_server(sig)
    assert_records([ActiveRecord, background, 'running'],
                   [ActiveRecord, @timeclock, 'paused'])
    assert_jobs('hobby', 'background')

                                                    # PAUSE_WITHOUT_RESUMPTION
    # Need to start timeclock again first.
    @session.start(@timeclock, Time.now)
    @session.pause_without_resumption(Time.now)
    bounce_server(sig)
    assert_records([ActiveRecord, background, 'paused'],
                   [ActiveRecord, @timeclock, 'paused'])
    assert_jobs('hobby', 'background')
    
                                                               # STOP
    @session.stop(@timeclock, Time.now)
    bounce_server(sig)
    assert_records([ActiveRecord, background, 'running'],
                   [FinishedRecord, @timeclock])
    assert_jobs('hobby', 'background')

                                                               # QUICK_STOP
    @session.quick_stop(Time.now)
    bounce_server(sig)
    assert_records([FinishedRecord, background],
                   [FinishedRecord, @timeclock])
    assert_jobs('hobby', 'background')
                                                               # STOP_ALL
    @session.start(background, Time.now)
    sleep 1 # ensure some time has passed.
    @session.start(@timeclock, Time.now)
    @session.stop_all(Time.now)
    bounce_server(sig)
    assert_records([FinishedRecord, background],
                   [FinishedRecord, @timeclock],
                   [FinishedRecord, background],
                   [FinishedRecord, @timeclock])
    assert_jobs('hobby', 'background')
    
                                                               # ADD_RECORD
    @session.add_record(FinishedRecord.new(Time.now, 1.hour, @hobby))
    bounce_server(sig)
    assert_records([FinishedRecord, background],
                   [FinishedRecord, @timeclock],
                   [FinishedRecord, background],
                   [FinishedRecord, @timeclock],
                   [FinishedRecord, @hobby])
    assert_jobs('hobby', 'background')

                                                               # SHORTEN
    records = @session.records
    @session.shorten(records.last.persistent_id, 30.minutes)
    bounce_server(sig)
    assert_records([FinishedRecord, background],
                   [FinishedRecord, @timeclock],
                   [FinishedRecord, background],
                   [FinishedRecord, @timeclock],
                   [FinishedRecord, @hobby])
    assert_jobs('hobby', 'background')
    records = @session.records
    assert_equal(30.minutes, records.last.time_accumulated)

                                                               # FORGET_RECORDS
    @session.forget_records(records[1], records[3])
    bounce_server(sig)
    assert_records([FinishedRecord, background],
                   [FinishedRecord, background],
                   [FinishedRecord, @hobby])
    assert_jobs('hobby', 'background')
    
                                                               # EMPTY_SESSION!
    @session.empty_session!
    bounce_server(sig)
    assert_records()
    assert_jobs()

  end

  def bounce_server(sig)
    ServerManager.kill(sig)
    ServerManager.connect
    @session = ServerManager.session_for(PRODUCT_TEST_USER)
  end

  def assert_jobs(*expected)
    jobs = @session.jobs
    assert_equal(expected.length, jobs.length)
    expected.each { | jobname |
      assert(jobs.has_key?(jobname), jobname)
    }
  end

  def assert_records(*expected)
    records = @session.records
    assert_equal(expected.length, records.length)
    expected.each_index { | index |
      assert_equal(expected[index][0], records[index].class)
      assert_equal(expected[index][1], records[index].job)
      if (records[index].is_a? ActiveRecord)
        assert(records[index].send(expected[index][2]+"?"))
      end
    }
  end
        
end

