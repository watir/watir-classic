require 'util'
require 'timeclock/util/Time'

=begin

Timing is done on the server side. Seems like it might make more sense
to do it on the client, but this is an experiment in keeping the
client as thin as possible.

=end

class ClockUsageTest < ProductTestCase

  ## Utilities

  def setup
    super

    stqe = create_job_both_sides('stqe')
    create_subjob_both_sides('kaner - usage testing', stqe)
    create_job_both_sides('misc. email')
  end



  ## Utilities - Assertions

  def assert_new_record(number, job, started_when)
    records = @session.records
    assert_equal(number, records.length, records)
    # Not bothering to check that old records are unchanged.

    new_record = records[number-1]
    assert_equal(job, new_record.job, new_record.inspect)
    assert_equal(started_when, new_record.time_started, new_record.inspect)
  end

  def assert_stopped_with(record_number, seconds)
    record = @session.records[record_number-1]
    assert_equal(seconds, record.time_accumulated)
  end


  ## Tests

  # This is a simple test. It checks that the printed representation
  # of the records looks right. Other tests check the stored values
  # directly, don't use the stringifier.

  def test_one_job_at_a_time_timing
    stqe = @session.jobs['stqe']
    kaner = stqe.subjobs['kaner - usage testing']

    now = Time.local('2002', 2, 19)
    @session.start(kaner, now)
    now += 50.minutes
    @session.stop(kaner, now)

    @session.start(stqe, now)
    now += 3.minutes
    @session.stop(stqe, now)

    now += 35.minutes

    @session.start(stqe, now)
    now += (1.hour+6.minutes)
    @session.stop(stqe, now)

    records = @session.records
    assert_equal(3, records.length)

    stringifier = RecordStringifier.new(records[0])
    assert_equal('stqe', stringifier.job)
    assert_equal('kaner - usage testing', stringifier.subjob)
    assert_equal('02002/02/19 12:00 AM', stringifier.start_date_time)
    assert_equal(' 0.83 hours', stringifier.cumulative_hours)

    stringifier = RecordStringifier.new(records[1])
    assert_equal('stqe', stringifier.job)
    assert_equal('', stringifier.subjob)
    assert_equal('02002/02/19 12:50 AM', stringifier.start_date_time)
    assert_equal(' 0.05 hours', stringifier.cumulative_hours)
    
    stringifier = RecordStringifier.new(records[2])
    assert_equal('stqe', stringifier.job)
    assert_equal('', stringifier.subjob)
    assert_equal('02002/02/19  1:28 AM', stringifier.start_date_time)
    assert_equal(' 1.10 hours', stringifier.cumulative_hours)
  end

  # Notes on test_start_pause_stop_combinations
  # Here are some test ideas for the state machine. This gives def-use
  # coverage.

  #    A started because start pressed; it stops because stop pressed
  #    A started because start pressed; it pauses because pause pressed
  #    A started because start pressed; it pauses because B was started

  #    A paused because pause pressed; it stops because stop pressed
  #    A paused because pause pressed; it starts because start pressed

  #    A paused because other job started; it stops because stop pressed
  #    A paused because other job started; it starts because start pressed

  #    A started after pause; it stops because stop pressed
  #    A started after pause; it pauses because pause pressed
  #    A started after pause; it pauses because B was started

  def test_start_pause_stop_combinations
    stqe = @session.jobs['stqe']
    kaner = stqe.subjobs['kaner - usage testing']
    mail = @session.jobs['misc. email']

    # A simple start->stop
                            mail_start = @now
    start(mail) # record 1
                            assert_states([mail], [])
                            assert_new_record 1, mail, mail_start
    stop(mail)  # record 1 stops
                            assert_states([], [])
                            assert_stopped_with(1, 1.minute)

    # A simple start->pause->stop
                            stqe_start = @now
    start(stqe) # record 2
                            assert_states([stqe], [])
                            assert_new_record 2, stqe, stqe_start
    pause
                            assert_states([], [stqe])
    stop(stqe)  # record 2 stops
                            assert_states([], [])
                            assert_stopped_with(2, 1.minute)

    # Now, two jobs at once.
                            stqe_start = @now
    start(stqe) # record 3
                            assert_states([stqe],[])
                            assert_new_record 3, stqe, stqe_start
                            mail_start = @now
    start(mail) # record 4
                            assert_states([mail],[stqe])
                            assert_new_record 4, mail, mail_start
    pause
                            assert_states([], [mail, stqe])
    start(mail) 
                            assert_states([mail], [stqe])
    pause
                            assert_states([], [mail, stqe])
    start(mail)
                            assert_states([mail], [stqe])
    stop(mail)  # record 4 stops
                            assert_states([], [stqe])
                            assert_stopped_with(4, 3.minutes)
    start(stqe)
                            assert_states([stqe], [])
    stop(stqe)  # record 3 stops
                            assert_states([], [])
                            assert_stopped_with(3, 2.minutes)

    # Three jobs
                            kaner_start = @now
    start(kaner) # record 5
                            assert_states([kaner], [])
                            assert_new_record 5, kaner, kaner_start
                            stqe_start = @now
    start(stqe)  # record 6
                            assert_states([stqe], [kaner])
                            assert_new_record 6, stqe, stqe_start
    pause
                            assert_states([], [stqe, kaner])
    start(stqe)
                            assert_states([stqe], [kaner])
    start(kaner)
                            assert_states([kaner], [stqe])
    pause
                            assert_states([], [kaner, stqe])
                            mail_start = @now
    start(mail) # record 7
                            assert_new_record 7, mail, mail_start
                            assert_states([mail], [kaner, stqe])
    start(stqe)
                            assert_states([stqe], [mail, kaner])
    start(mail)
                            assert_states([mail], [stqe, kaner])
    start(stqe)
                            assert_states([stqe], [mail, kaner])
    stop(stqe)  # record 6 stops
                            assert_states([], [mail, kaner])
                            assert_stopped_with(6, 4.minutes)
    start(kaner)
                            assert_states([kaner], [mail])
    stop(kaner) # record 5 stops
                            assert_states([], [mail])
                            assert_stopped_with(5, 3.minutes)
    stop(mail)  # record 7 stops
                            assert_states([], [])
                            assert_stopped_with(7, 2.minutes)

    # Loose ends - pausing due to other jobs
                            stqe_start = @now
    start(stqe) # record 8 
                            assert_states([stqe], [])
                            assert_new_record 8, stqe, stqe_start
    pause
                            assert_states([], [stqe])
                            kaner_start = @now
    start(kaner) # record 9 
                            assert_states([kaner], [stqe])
                            assert_new_record 9, kaner, kaner_start
    start(stqe)
                            assert_states([stqe], [kaner])
    stop(stqe)   # record 8 stops
                            assert_states([], [kaner])
                            assert_stopped_with(8, 2.minutes)
    stop(kaner)  # record 9 stops
                            assert_states([], [])
                            assert_stopped_with(9, 1.minute)
  end

  # Later addition: You can pause two jobs and pick which one to stop.
  # The above tests were written when that was impossible - you could
  # only stop the started job.
  def test_more_than_one_pause_when_stopping
    stqe = @session.jobs['stqe']
    mail = @session.jobs['misc. email']

                            stqe_start = @now
    start(stqe)
                            assert_states([stqe], [])
                            assert_new_record 1, stqe, stqe_start
                            mail_start = @now
    start(mail)
                            assert_states([mail], [stqe])
                            assert_new_record 2, mail, mail_start
    pause
                            assert_states([], [mail, stqe])
    stop(stqe)
                            assert_states([], [mail])
                            assert_stopped_with(1, 1.minute)
    stop(mail)
                            assert_states([], [])
                            assert_stopped_with(2, 1.minute)
  end

  todo 'what happens if you send weekly report on 3 am november 1st'
end  

