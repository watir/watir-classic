require 'timeclock/client/command-line/tutil.rb'

module Timeclock
  module Client
    module CommandLine

      class InterfaceUndoActionTests < InterfaceTestCase

                     ###  Generic undo tests. ###

        def test_undo_with_nothing_to_undo
          assert_message(nothing_to_undo, undo)

          # Some records are not undoable because they don't do anything.
          records
          assert_message(nothing_to_undo, undo)
        end

        def test_undo_ignores_actions_that_do_not_change_state
          job 'hi'
          add_record '9:00 PM', 0.minutes, 'hi'
          assert_equal(1, @session.records.length)

          records
          active
          jobs

          assert_match(forgot_record_re('hi'), undo)
          assert_equal(0, @session.records.length)
        end

        def test_N_level_undo
          job 'hi'
          job 'bye'

          # By doing this twice, we check whether the "undo pointer"
          # is correctly updated.

          0.upto(3) { 
            add_record '9:00 AM', 0.minutes, 'hi'
            add_record '9:00 PM', 0.minutes, 'bye'
            assert_match(forgot_record_re('bye'), undo)
            assert_match(forgot_record_re('hi'), undo)
            assert_equal(0, @session.records.length)
          }
        end

        def test_failure_does_not_change_undo
          add_record 0.minutes
          undo
          assert_message(nothing_to_undo, undo)
        end

        def test_undo_erases_pause_memory
          job 'job'
          start 'job'
          assert(@session.running?('job'))


          pause
          records
          lengthen 1, 1.hour
          undo

          # Normally, an intervening lengthen would not interfere with
          # quick-starting from a pause. But all undos erase pause memeory.
          assert_match(bad_quick_start_re, start)
          
          # Check that the undo really happened.
          assert_match(/ 0.00 hours/, records)

          # And, for laughs, undo the pause and start.
          undo
          undo
          assert_equal(record_list(0.hours), records)
          assert @session.active_records.empty?
        end

                    ### Various command tests. ###

        ## add_record

        def test_undo_add_record
          job 'undo'
          add_record 'undo', 'yesterday 8:00 AM', 1.hour
          assert_equal(1, @session.records.length)
          assert_equal(lines(undid_prefix('add_record'),
                             "Forgot this record:  1.00 hour  from  8:00 AM yesterday on undo"),
                       undo)
          assert_equal(0, @session.records.length)
        end

        
        ## shorten, lengthen

        def test_undo_shorten_and_lengthen
          job 'change'
          add_record 'change', 1.hour, '2002/03/04 15:00'
          mark = Time.local(2002, 3, 4, 15)
          records
          shorten 1, 30.minutes
          assert_equal(30.minutes, @session.records[0].time_accumulated)
          undo_result = undo
          assert_equal(lines(undid_prefix('shorten'),
                             changed_accumulated_time(mark, 1.hour, 'change')),
                       undo_result)
          assert_equal(1.hour, @session.records[0].time_accumulated)

          lengthen 1, 30.minutes
          assert_equal(1.hour+30.minutes, @session.records[0].time_accumulated)
          undo_result = undo
          assert_equal(lines(undid_prefix('lengthen'),
                             changed_accumulated_time(mark, 1.hour, 'change')),
                       undo_result)
          assert_equal(1.hour, @session.records[0].time_accumulated)

          # For laughs undo the whole record addition.
          assert_match(forgot_record_re('change'), undo)
          assert_equal(0, @session.records.length)
        end

        

        ## background
        
        def test_undo_background
          job 'first-background'
          job 'second-background'
          job 'ordinary'

          # # Undo creating the first background
          background 'first-background'
          message = undo
          assert_message("#{undid_prefix 'background'}
                          'first-background' is no longer the background job.
                          The job still exists and can be used in the ordinary way.",
                         message)
          # check behavior
          assert_match(/But there is no background job./m, start_day)

          # Undo swapping background jobs.
          background 'first-background'
          background 'second-background'
          message = undo
          assert_message("#{undid_prefix 'background'}
                          'second-background' is no longer the background job.
                          It has been replaced by 'first-background'.
                          This change will take effect the next time you use 'start_day'.
                          Thereafter, 'first-background' will resume recording time when other jobs pause or stop.",
                         message)

          # check behavior
          start_day
          assert_equal(true, @session.running?('first-background'))
          assert_equal(true, @session.stopped?('second-background'))
          start 'second-background'
          pause
          assert_equal(true, @session.running?('first-background'))
          assert_equal(true, @session.paused?('second-background'))
          pause 
          assert_equal(true, @session.paused?('first-background'))
          assert_equal(true, @session.paused?('second-background'))
        end

        # More background - just to show typical uses.
        def test_undo_ineffectual_background_setting
          job 'jobber'
          start 'jobber'
          background 'jobber'  # this takes effect after start_day

          undo

          stop 'jobber'
          # There is no background job...
          assert_equal(false, @session.jobs['jobber'].is_background?)
          message = start_day
          assert_match(no_background_job_re, message)
        end

        def test_undo_through_start_day
          job 'background'
          background 'background'
          start_day

          undo
          undo

          assert_equal(0, @session.records.length)
          message = start_day
          assert_match(no_background_job_re, message)

          message = start 'background'
          assert_match(started_re('background'), message)
        end


        ## forget_record
          
        def test_undo_forget_finished_record
          job 'simple-case'

          mark = Time.local(2002, 12, 3, 12, 51)
          Time.set(mark)
          start 'simple-case'
          stop 'simple-case'

          recs = @session.records
          original_record = recs[0]

          records
          forget 1
          assert_equal(0, @session.records.length)

          message = undo
          assert_message(lines(undid_prefix('forget'),
                               put_back_rec(mark, 0.minutes, 'simple-case')),
                         message)
          assert_equal(1, @session.records.length)
          assert_equal(original_record, @session.records[0])
        end


        def test_undo_forget_active_record
          mark = Time.local(2002, 12, 3, 12, 51)
          Time.set(mark)
          job 'started-job-forgotten'

          start 'started-job-forgotten'
          records
          forget(1)

          message = undo
          assert_message(lines(undid_prefix('forget'),
                               undid_stop(mark, 0.hours,
                                          'started-job-forgotten', 'running')),
                         message)
        end

        def test_undo_forget_multiple_records
          job 'old-job-1'
          job 'old-job-2-forgotten'
          job 'old-job-3'
          job 'started-job-forgotten'
          job 'paused-job-forgotten'
          job 'ordinary-paused-job'
          
          mark = Time.local(2002, 12, 3, 12, 51)
          Time.set(mark)
          # starting these in odd orders to emphasize that ordering
          # is by start time.
          add_record('old-job-3', '13-aug-2002 12:00 am', 1.hour)
          add_record('old-job-2-forgotten', '13-aug-2001 12:00 am', 1.hour)
          add_record('old-job-1', '13-aug-2000 12:00 am', 1.hour)
          Time.advance 1.hour
          start 'started-job-forgotten'
          Time.advance 1.hour
          start 'paused-job-forgotten'
          Time.advance 2.hours
          start 'ordinary-paused-job'
          Time.advance 1.minute
          start 'started-job-forgotten'
          Time.advance 3.hours

          check_jobs = proc {
            recs = @session.records
            assert_equal('old-job-1', recs[0].job.full_name)
            assert_equal('old-job-2-forgotten', recs[1].job.full_name)
            assert_equal('old-job-3', recs[2].job.full_name)
            assert_equal('started-job-forgotten', recs[3].job.full_name)
            assert_equal('paused-job-forgotten', recs[4].job.full_name)
            assert_equal('ordinary-paused-job', recs[5].job.full_name)
          }
          check_activity = proc {
            assert_equal(true, @session.running?('started-job-forgotten'))
            assert_equal(true, @session.paused?('paused-job-forgotten'))
            assert_equal(true, @session.paused?('ordinary-paused-job'))
          }
          check_jobs.call
          check_activity.call

          records
          forget(2, 4, 5)

          # Note that the time that elapsed since the running job was
          # stopped counts as time spent on the job. 
          Time.advance(30.minutes)

          message = undo
          # Note the messages come in reverse order from original
          # arguments.
          assert_message(lines(undid_prefix('forget'),
                               undid_stop(mark+2.hours, 2.hours,
                                          'paused-job-forgotten', 'paused'),
                               undid_stop(mark+1.hour, 4.hours+30.minutes,
                                          'started-job-forgotten', 'running'),
                               put_back_rec(Time.local(2001, 8, 13), 1.hour,
                                            'old-job-2-forgotten')),
                         message)

          check_jobs.call
          check_activity.call

          # Check that active jobs can be used in normal ways.
          Time.advance(30.minutes)
          start 'paused-job-forgotten'
          Time.advance(30.minutes)

          assert_match(stopped_re('paused-job-forgotten'),
                       stop('paused-job-forgotten'))
          assert_match(stopped_re('started-job-forgotten'),
                       stop('started-job-forgotten'))
          check_jobs.call
          assert_equal(true, @session.stopped?('started-job-forgotten'))
          assert_equal(true, @session.stopped?('paused-job-forgotten'))

          # Are the fields correct?
          st_rec = @session.records[3]
          assert_equal('started-job-forgotten', st_rec.job.full_name)
          assert_equal(mark+1.hour, st_rec.time_started)
          assert_equal(5.hours, st_rec.time_accumulated)

          pa_rec = @session.records[4]
          assert_equal('paused-job-forgotten', pa_rec.job.full_name)
          assert_equal(mark+2.hours, pa_rec.time_started)
          assert_equal(2.hours+30.minutes, pa_rec.time_accumulated)
        end

        def test_undo_forget_forgotten_record
          job 'j'
          start 'j'
          stop 'j'
          original_record = @session.records[0]

          records

          forget 1
          assert_match(/no such record/, forget(1))
          assert_equal(0, @session.records.length)

          message = undo
          assert_message(undo_with_no_op_command('forget'),
                         message)

          message = undo
          assert_match(put_back_rec_re, message)
          assert_equal(original_record, @session.records[0])
        end

        def test_undo_forget_duplicate_records
          # This test dedicated to Elisabeth Hendrickson.
          job 'esh'

          add_record 1.hour, 'esh', "2001/12/11 2:13"
          add_record 1.hour, 'esh', "2001/12/11 2:13"
          mark = Time.local(2001, 12, 11, 2, 13)

          undo

          assert_message(record_list(1.hour,
                                     [mark, 1.hour, 'esh']),
                         records)
        end


        ## start 

        def test_undo_first_start_job
          job 'j'

          mark = Time.set(Time.now)
          start 'j'
          Time.advance 1.hour
          
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_first_start(mark, 1.hour, 'j')),
                         message)

          assert_message(record_list(0.hours), records)
          assert_match(stop_error_re('j'), stop('j'))
        end

        def test_undo_start_job_that_resumed_same_job
          # Like previous test, but with an additional start-stop
          # cycle to check that only the right amount of time is "lost".
          job 'j'

          mark = Time.set(Time.local(2002, 12, 16, 13, 23))
          start 'j'
          Time.advance 1.hour
          pause
          Time.advance 2.hours
          start 'j'
          Time.advance 3.hours
          
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_restart("4:23 PM", 'j')),
                         message)

          assert_message(record_list(1.hour, [mark, 1.hour, 'j', 'paused']),
                         records)
          assert(@session.paused?('j'))
          assert_message(stopped(mark, 1.hour, 'j'), stop('j'))
          assert(@session.stopped?('j'))
        end

        def test_undo_start_job_that_paused_other_job
          job 'old'
          job '-'

          mark = Time.set(Time.now)
          start '-'
          Time.advance 30.minutes
          start 'old'
          Time.advance 1.hour
          start '-'
          Time.advance 2.hours
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_pausing_start(2.hours, '-', 'old', "resumed")),
                         message)
          assert_message(record_list(3.hours + 30.minutes,
                                     [mark, 30.minutes, '-', 'paused'],
                                     [mark+30.minutes, 3.hours, 'old', 'running']
                                     ),
                         records)

          Time.advance 3.hours
          stop_day
          assert_message(record_list(6.hours + 30.minutes,
                                     [mark, 30.minutes, '-'],
                                     [mark+30.minutes, 6.hours, 'old']
                                     ),
                         records)
        end

        def test_undo_start_from_all_paused_state
          job 'unstarted'
          job 'started'

          mark = Time.set(Time.local(2002, 12, 15, 11, 13))
          start 'unstarted'
          Time.advance 1.hour
          start 'started'
          Time.advance 2.hours
          pause_day
          assert(@session.paused?('unstarted'))
          assert(@session.paused?('started'))

          Time.advance 3.hours
          start 'started'
          Time.advance 10.minutes  # This time is lost on undo.
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_restart("5:13 PM", 'started')),
                         message)

          assert_message(record_list(3.hours,
                                     [mark, 1.hour, 'unstarted', 'paused'],
                                     [mark+1.hour, 2.hours, 'started', 'paused']),
                         records)

          start 'started'
          Time.advance 4.hours
          
          assert_message(record_list(7.hours,
                                     [mark, 1.hour, 'unstarted', 'paused'],
                                     [mark+1.hour, 6.hours, 'started', 'running']),
                         records)

        end


        # Like above, but just check whether messages show the date nicely
        # when the undo goes way back in time. 
        def test_undo_start_date_messages
          job 'started'

          mark = Time.set(Time.local(2002, 3, 23, 22, 13))
          start 'started'
          Time.advance 1.minute
          pause_day

          start 'started'
          Time.advance 3.hours
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_restart("10:14 PM yesterday", 'started')),
                         message)

          start 'started'   # At 1:14 AM
          Time.set(Time.local(2002, 3, 26))

          message = undo
          # This makes for a pretty lame error message, but how often
          # will people undo something a couple of days in the past?
          assert_message(lines(undid_prefix('start'),
                               undid_restart("02002/03/24 1:14 AM", 'started')),
                         message)

          stop_day

          assert_message(record_list(1.minute,
                                     [mark, 1.minute, 'started']),
                         records)
        end

        def test_undo_fresh_start_pauses_old_job
          job 'old'
          background 'old'

          job 'j'

          mark = Time.set(Time.local(2002, 12, 15, 12, 2))
          start_day
          Time.advance 10.minute
          start 'j'
          Time.advance 20.minutes
          message = undo

          assert_message(lines(undid_prefix('start'),
                               undid_pausing_start(20.minutes, 'j', 'old', "started")),
                         message)
          
          assert_message(record_list(30.minutes,
                                     [mark, 30.minutes, 'old', 'running']),
                         records)

          # Check whether further operations work - a frill.
          Time.advance 30.minutes
          pause
          assert_message(record_list(60.minutes,
                                     [mark, 60.minutes, 'old', 'paused']),
                         records)
        end

        def test_lost_time_messages_only_appear_when_relevant
          # Since this is a complex test, take the opportunity to
          # check what goes on behind the scenes. Had I done this
          # originally, I would have caught a bug. 
          job 'job'

          # undoing the first start
          Time.set(Time.now)

          start 'job'
          Time.advance(10.seconds)
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_first_start_quickly('job')),
                         message)
          assert_equal(true, @session.stopped?('job'))

          # undoing a restart
          start 'job'
          Time.advance(1.hour) # This time is irrelevant to the messages.
          pause

          start 'job'
          Time.advance(20.seconds)
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_restart_quickly('job')),
                         message)
          assert_equal(true, @session.paused?('job'))

          stop_day

          # undoing a pausing start
          job 'background'
          background 'background'

          start_day

          start 'job'
          Time.advance(1.hour) # This time is irrelevant to the messages.
          pause
          
          start 'job'
          Time.advance(30.seconds)
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_pausing_start_quickly('background')),
                         message)
          assert_equal(true, @session.running?('background'))
          assert_equal(true, @session.paused?('job'))
        end

        def test_undo_does_not_incorrectly_resume_background_job
          job 'background'
          background 'background'

          job 'first'
          job 'second'

          start_day
          start 'first'
          start 'second'

          ## Undoing 'second' means stopping it. It must be 'first' that
          # restarts, not the background job. (And not both! - as was a bug.) 
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_pausing_start_quickly('first')),
                         message)
          # It's all very well for the *message* to be correct - but is
          # the underlying state correct?
          assert_equal(true, @session.running?('first'))
          assert_equal(true, @session.stopped?('second'))
          assert_equal(true, @session.paused?('background'))

          # To double-check, undo further.
          message = undo
          assert_message(lines(undid_prefix('start'),
                               undid_pausing_start_quickly('background')),
                         message)
          assert_equal(true, @session.stopped?('first'))
          assert_equal(true, @session.stopped?('second'))
          assert_equal(true, @session.running?('background'))
        end

        def test_undo_does_not_resume_paused_background_job
          job 'background'
          background 'background'

          job 'job'

          start_day
          pause
          start 'job'
          message = undo

          assert_message(lines(undid_prefix('start'),
                               undid_first_start_quickly('job')),
                         message)
          assert_equal(true, @session.stopped?('job'))
          assert_equal(true, @session.paused?('background'))
        end


        ## quick_start 
        # quick_start is just like start
        # Just testing the 'oops - undo quickly' version is sufficient
        # to show they're the same.

        def test_undo_quick_start
          job 'jobbist'

          start 'jobbist'
          pause
          start
          message = undo
          assert_message(lines(undid_prefix('quick_start'),
                               undid_restart_quickly('jobbist')),
                         message)

          job 'background'
          background 'background'

          stop_day
          start_day
          start 'jobbist'
          pause
          start

          message = undo
          assert_message(lines(undid_prefix('quick_start'),
                               undid_pausing_start_quickly('background')),
                         message)

          # For laughs, undo way back.
          assert_match(undid_re('pause'), undo)         # undo pause
          assert(@session.running?('jobbist'))
          assert(@session.paused?('background'))

          assert_match(undid_re('start'), undo)         # undo start jobbist
          assert(@session.stopped?('jobbist'))
          assert(@session.running?('background'))
          
          assert_match(undid_re("start_day"), undo)     # undo start_day
          assert(@session.stopped?('jobbist'))
          assert(@session.stopped?('background'))

          assert_match(undid_re('stop_day'), undo)      # undo stop_day
          # This puts us back to the pause of jobbist because the start
          # was undone.
          assert(@session.paused?('jobbist'))

          assert(@session.jobs['background'].is_background?)
          assert_match(undid_re('background'), undo)    # undo background
          assert_equal(false, @session.jobs['background'].is_background?)

          assert_match(undid_re("job"), undo)           # undo job
          assert_equal(false, @session.jobs.has_key?('background'))

          assert_match(undid_re('pause'), undo)         # pause jobbist
          assert(@session.running?('jobbist'))

          assert_match(undid_re('start'), undo)         # start jobbist
          assert(@session.active_records.empty?)
          assert(@session.records.empty?)

          assert_match(undid_re('job'), undo)           # job 'jobbist'
          assert(@session.jobs.empty?)
        end


        ## Start_day

        def test_undo_start_day
          job 'stqe'
          job 'timeclock'
          job 'misc'
          background 'misc'

          mark = Time.set(Time.local(2002, 12, 19, 11, 33))
          # Setup - let's run a previous day, just for variety.
          start_day
          Time.advance(1.minute)
          start 'stqe'
          Time.advance(2.minutes)
          pause_day
          Time.advance(3.minutes)
          start 'timeclock'
          Time.advance(4.minutes)
          pause
          Time.advance(5.minutes)
          start
          Time.advance(6.minutes)
          stop_day

          # Now let's do this day.
          final_mark = Time.set(Time.local(2002, 12, 20, 8))
          Time.set(Time.local(2002, 12, 20, 10))
          start_day
          message = undo
          assert_message(lines(undid_prefix('start_day'),
                               "No job is active."),
                         message)
          assert(@session.active_records.empty?)

          # Intend retroactive start at 8 in the morning, but typo
          at "9:00 AM" do start_day end
          Time.advance(20.minutes)  # it's now 10:20

          # No, I mean *8*!
          message = undo
          assert_message(lines(undid_prefix('start_day'),
                               "No job is active."),
                         message)
          assert(@session.active_records.empty?)

          Time.advance(1.minute)   # It's now 10:21
          at "8:00 AM" do start_day end # So 2 hours and 21 minutes have elapsed.
          final_time_mark = Time.advance(1.hour)
          start 'timeclock'        # 3 hours and 21 minutes for misc.
          Time.advance(2.hours)
          pause
          Time.advance(3.hours)    # 6 hours and 21 minutes for misc

          assert_message(record_list(8.hours+39.minutes,
                                     [mark, 6.minutes, 'misc'],
                                     [mark+1.minute, 2.minutes, 'stqe'],
                                     [mark+6.minutes, 10.minutes, 'timeclock'],
                                     [final_mark, 6.hours+21.minutes, 'misc', 'running'],
                                     [final_time_mark, 2.hours, 'timeclock', 'paused']),
                         records)
        end
          

        ## stop
        
        def test_simple_undo_stop_job
          job 'j'

          mark = Time.set(Time.now)
          start 'j'
          Time.advance(1.hour)
          stop 'j'
          Time.advance(1.hour)
          # Note that the undoing causes time since the stop to be recorded.
          message = undo
          assert_message(lines(undid_prefix('stop'),
                               undid_stop(mark, 2.hours, 'j', 'running')),
                         message)
          Time.advance(1.hour)
          stop 'j'
          assert_message(record_list(3.hours, [mark, 3.hours, 'j']),
                         records)
        end

        def test_undo_stop_background_job
          job 'b-j'
          background 'b-j'

          start_day
          stop 'b-j'
          message = undo
          assert_match(undid_stop_re('b-j'), message)

          # Is b-j behaving as a background job?
          job 'j'
          start 'j'
          pause
          assert_equal(true, @session.paused?('j'))
          assert_equal(true, @session.running?('b-j'))
        end

        # Stopping a job that resumes the background job is tested
        # via quick_stop.


        ## stop_day

        def test_undo_stop_day
          job 'background'
          background 'background'
          job 'other'
          job 'yet-another'

          b_mark = Time.set(Time.now)
          start_day
          o_mark = Time.advance 1.minute
          start 'other'
          y_mark = Time.advance 2.minutes
          start 'yet-another'
          Time.advance 3.minutes

          stop_day

          assert(@session.active_records.empty?)
          Time.advance 4.minutes
          message = undo
          # Note that jobs are printed in reverse start order.
          assert_message(lines(undid_prefix('stop_day'),
                               undid_stop(y_mark, 7.minutes, 'yet-another', 'running'),
                               undid_stop(o_mark, 2.minutes, 'other', 'paused'),
                               undid_stop(b_mark, 1.minute, 'background', 'paused')),
                         message)

          # Check expected behavior.
          Time.advance 1.hour
          start 'other'
          Time.advance 2.hours
          start 'yet-another'
          Time.advance 5.minutes

          assert_match(stopped_re('yet-another'), stop)
          Time.advance(6.minutes)
          assert_match(stopped_re('background'), stop)
          Time.advance(7.minutes)
          assert_match(stopped_re('other'), stop('other'))

          assert_message(record_list(3.hours+21.minutes,
                                     [b_mark, 7.minutes, 'background'],
                                     [o_mark, 2.hours + 2.minutes, 'other'],
                                     [y_mark, 1.hour+12.minutes, 'yet-another']),
                         records)
        end

        def test_undo_stop_day_with_nothing_to_stop
          job 'background'
          # Forgot to make it background, so this fails:
          assert_match(no_background_job_re, start_day)
          # As does this...
          assert_match(stop_day_error_re, stop_day)
          assert_message(undo_with_no_op_command('stop_day'), undo)
        end


        ## quick_stop - just like stop.

        def test_undo_quick_stop_no_resumption
          job 'kvik'

          mark = Time.set(Time.now)
          start 'kvik'
          Time.advance(30.hours)
          stop
          Time.advance(3.minutes)

          message = undo
          assert_message(lines(undid_prefix('quick_stop'),
                               undid_stop(mark, 30.hours + 3.minutes,
                                          'kvik', 'running')),
                         message)
          Time.advance(10.minutes)
          assert_message(record_list(30.hours + 13.minutes,
                                     [mark, 30.hours+13.minutes, 'kvik', 'running']),
                         records)
        end

        def test_undo_quick_stop_resume_background
          job 'foreground'
          job 'background'
          background 'background'

          b_mark = Time.set(Time.now)
          start_day

          f_mark = Time.advance(1.hour)
          start 'foreground'

          Time.advance(2.hours)
          stop

          Time.advance(2.minutes)
          message = undo
          assert_message(lines(undid_prefix('quick_stop'),
                               undid_resuming_action(b_mark, 1.hour,
                                                    'background'),
                               undid_stop(f_mark, 2.hours+2.minutes,
                                          'foreground', 'running')),
                         message)
        end


        ## Pause

        def test_undo_simple_pause
          # Pause the only job.
          job 'pauser'
          mark = Time.set(Time.local(2002, 12, 9, 23, 44))
          start 'pauser'
          Time.advance(1.hour)
          pause
          Time.advance(1.hour)
          message = undo
          assert_message(lines(undid_prefix('pause'),
                               undid_pause(mark, 2.hours, 'pauser', 'running')),
                         message)
          assert(@session.running?('pauser'))

          # Pause one of two jobs (but other is not background)
          
          job 'other'
          start 'other'
          assert(@session.running?('other'))
          assert(@session.paused?('pauser'))
          Time.advance(1.hour)
          start 'pauser'
          assert(@session.running?('pauser'))
          assert(@session.paused?('other'))
          Time.advance(1.hour)
          pause
          Time.advance(1.hour)
          message = undo
          assert_message(lines(undid_prefix('pause'),
                               undid_pause(mark, 4.hours, 'pauser', 'running')),
                         message)
          assert(@session.running?('pauser'))
          assert(@session.paused?('other'))

          pause
          Time.advance(1.hour)
          assert(@session.paused?('pauser'))
          assert(@session.paused?('other'))
          Time.advance(1.hour)
          stop 'pauser'
          assert(4.hours, @session.records.last.time_accumulated)
        end

        def test_undo_pause_that_resumes_background_job
          job 'background'
          background 'background'
          job 'pauser'

          mark = Time.set(Time.local(2002, 12, 10, 8, 32))
          start_day
          Time.advance(1.minute)
          start 'pauser'
          pause
          Time.advance(30.minutes)
          message = undo
          assert_message(lines(undid_prefix('pause'),
                               undid_resuming_action(mark, 1.minute,
                                                    'background'),
                               undid_pause(mark+1.minute, 30.minutes,
                                           'pauser', 'running')),
                         message)
          
          Time.advance(30.minutes)
          # Pauser accumulates the time that was "undone".
          assert_equal(60.minutes, @session.records[1].time_accumulated)
          # The background job does not.
          assert_equal(1.minute, @session.records[0].time_accumulated)
          # Background job still works as a background job.
          message = stop
          assert_message(lines(stopped(mark+1.minute, 1.hour, 'pauser'),
                               resumed_background('background')),
                         message)
          assert(@session.running?('background'))
        end


        ## Pause_day

        def test_undo_pause_day
          job 'pauser'

          mark = Time.set(Time.now)
          start 'pauser'
          pause_day
          assert_message(".   1: #{rec(mark, 0.minutes, 'pauser', 'paused')}",
                       records)
                                 
          assert_message(record_list(0.minutes,
                                     [mark, 0.minutes, 'pauser', 'paused']),
                         records)
          
          Time.advance(30.minutes)
          message = undo
          assert_message(lines(undid_prefix('pause_day'),
                               undid_pause(mark, 30.minutes, 'pauser', 'running')),
                         message)

          # Check behavior.
          assert_message(record_list(30.minutes,
                                     [mark, 30.minutes, 'pauser', 'running']),
                         records)
          Time.advance(3.minutes)
          stop_day
          assert_message(record_list(33.minutes,
                                     [mark, 33.minutes, 'pauser']),
                         records)
        end

        def test_undo_pause_day_that_does_nothing
          job 'back'
          background 'back'
          job 'front'

          start_day
          start 'front'
          start 'back'
          pause

          pause_day   # This is an error - no job running.
          message = undo  # therefore, this undo undoes the pause.
          assert_match(undid_re('pause'), message)
        end

        def test_undo_pause_day_background
          job 'b'
          background 'b'
          job 'c'

          b_mark = Time.set(Time.local(2002, 12, 11, 14, 55))
          start_day
          c_mark = Time.advance(1.hour)
          start 'c'
          Time.advance(1.hour)
          pause
          Time.advance(1.hour)
          pause_day
          Time.advance(1.hour)
          message = undo
          assert_message(lines(undid_prefix('pause_day'),
                               undid_pause(b_mark, 3.hours, 'b', 'running')),
                         message)
          assert_message(record_list(4.hours,
                                     [b_mark, 3.hours, 'b', 'running'],
                                     [c_mark, 1.hour, 'c', 'paused']),
                         records)

          # For laughs, pause further back.
          Time.advance(1.hour)
          message = undo
          assert_message(lines(undid_prefix('pause'),
                               undid_resuming_action(b_mark, 1.hour, 'b'),
                               undid_pause(c_mark, 4.hours, 'c', 'running')),
                         message)
          assert_message(record_list(5.hours,
                                     [b_mark, 1.hour, 'b', 'paused'],
                                     [c_mark, 4.hour, 'c', 'running']),
                         records)
          Time.advance(1.hour)
          stop_day

          # And what should the final times be?
          assert_message(record_list(6.hours,
                                     [b_mark, 1.hour, 'b'],
                                     [c_mark, 5.hours, 'c']),
                         records)
        end


        ## job

        def test_undo_job
          job 'simple'
          message = undo
          assert_message(lines(undid_prefix('job'),
                               removed_job('simple')),
                         message)
          assert_message("", jobs)
          assert_match(no_job_re('simple'), start('simple/foo'))

          job 'simple/foo'
          message = undo
          assert_message(lines(undid_prefix('job'),
                               removed_job('simple/foo'),
                               removed_job('simple')),
                         message)
          assert_match(no_job_re('simple'), start('simple/foo'))

          job 'simple'
          job 'simple/bar'
          message = undo
          assert_message(lines(undid_prefix('job'),
                               removed_job('simple/bar')),
                         message)
          assert_match(no_subjob_re('simple','foo'),
                       start('simple/foo'))

          job 'uncreated/subjob'
          job 'uncreated/subjob'
          message = undo
          assert_message(undo_with_no_op_command('job'),
                         message)
          message = undo
          assert_message(lines(undid_prefix('job'),
                               removed_job('uncreated/subjob'),
                               removed_job('uncreated')),
                         message)
        end


        ## forget_job
        def test_undo_forget_job
          job 'job'
          forget_job 'job'
          message = undo
          assert_message(lines(undid_prefix('forget_job'),
                               added_back_job('job')),
                         message)

          assert_message("job", jobs)

          # Undo restores subjobs as well as jobs.
          job 'job/subjob'
          forget_job 'job'
          message = undo
          assert_message(lines(undid_prefix('forget_job'),
                               added_back_job_tree('job')),
                         message)
          assert_match(started_re('job/subjob'), start('job/subjob'))
          assert_equal(true, @session.running?('job/subjob'))
          assert_match(started_re('job'), start('job'))
          assert_equal(true, @session.running?('job'))

          # You can forget just a subjob.
          job 'job/subjob2'
          forget_job 'job/subjob2'
          message = undo
          assert_message(lines(undid_prefix('forget_job'),
                               added_back_job('job/subjob2')),
                         message)
          assert_match(started_re('job/subjob2'), start('job/subjob2'))
          assert_equal(true, @session.running?('job/subjob2'))
          assert_match(resumed_re('job'), start('job'))
          assert_equal(true, @session.running?('job'))

          # Just for kicks, note again that an error does not yield anything
          # to undo.
          stop 'job/subjob'
          forget_job 'job/subjobxxxxxxxxxx'
          
          message = undo
          assert_match(undid_re('stop'), message)
        end


        ## forget_background

        def test_undo_forget_background
          job 'background'
          background 'background'
          forget_background
          message = undo
          assert_message(lines(undid_prefix('forget_background'),
                               again_background('background')),
                         message)

          assert_match(started_re('background'), start_day)
        end

        def test_undo_forget_background_while_running
          job 'background'
          background 'background'
          start_day
          forget_background
          message = undo
          assert_message(lines(undid_prefix('forget_background'),
                               again_background('background')),
                         message)

          job 'other'
          start 'other'
          assert(@session.running?('other'))
          assert(@session.paused?('background'))
          pause
          assert(@session.running?('background'))

          stop_day
          assert(@session.stopped?('background'))

          start_day
          assert(@session.running?('background'))
        end

      end
    end
  end
end
