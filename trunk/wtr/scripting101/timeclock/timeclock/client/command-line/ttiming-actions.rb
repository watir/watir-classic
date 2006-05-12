require 'timeclock/client/command-line/tutil.rb'

module Timeclock
  module Client
    module CommandLine

      class InterfaceTimingActionTests < InterfaceTestCase

        ## active

        def test_active
          job('starting')
          job('paused job')
          job('paused job/paused subjob')
          job('quiescent')

          Time.set(Time.local(2002, 'apr', 15, 8))
          start('paused job');               Time.advance 1.hour   # at 8 a.m
          pause;                             Time.advance 1.hour   # at 9 a.m
          start('paused job/paused subjob'); Time.advance 10.hours  # at 10 a.m
          pause;                             Time.advance 30.minutes # at 8 p.m

          start('quiescent');                Time.advance 1.hour  # at 8:30 p
          stop('quiescent');                 Time.advance 1.hour  # at 9:30 p

          start('starting');                 Time.advance 15.minutes # at 10:30 p

          lines = active.split($/)                                # at 10:45 p
          assert_equal(4, lines.length)

          assert_equal("'starting' is running, with 0.25 hours from 10:30 PM.",
                       lines[0])
          assert_equal("Paused:", lines[1])
          assert_equal("'paused job', with 1.00 hour from 8:00 AM.",
                       lines[2])
          assert_equal("'paused job/paused subjob', with 10.00 hours from 10:00 AM.",
                       lines[3])
        end

        def test_active_time_extends_over_day
          job 'oldie'
          Time.set(Time.local(2002, 'feb', 28, 14, 30))
          start 'oldie'
          Time.advance(24.hours)
          lines = active.split($/)
          assert_equal(1, lines.length)
          assert_equal("'oldie' is running, with 24.00 hours from 2:30 PM yesterday.",
                       lines[0])

          pause
          Time.advance 24.hours
          lines = active.split($/)
          assert_equal(2, lines.length)
          assert_equal("Paused:", lines[0])
          assert_equal("'oldie', with 24.00 hours from 02002/02/28 2:30 PM.",
                       lines[1])
        end

        def test_active_run_no_pause
          Time.set(Time.local(1997, 'jul', 3, 8, 13))
          job 'sophie-born'
          start 'sophie-born'
          Time.advance 6.minutes

          assert_equal("'sophie-born' is running, with 0.10 hours from 8:13 AM.",
                       active)
        end

        def test_active_pause_no_run
          job 'boo'
          job 'hoo'

          Time.set(Time.local(2001, 'oct', 31, 22))
          start 'hoo'
          Time.advance 1.hour

          start 'boo'
          Time.advance 2.minutes
          pause
          Time.advance 3.minutes

          lines = active.split($/)
          assert_equal(3, lines.length)
          assert_equal("Paused:", lines[0])
          assert_equal("'boo', with 0.03 hours from 11:00 PM.", lines[1])
          assert_equal("'hoo', with 1.00 hour from 10:00 PM.", lines[2])
          
        end

        def test_active_nothing
          job 'quiet'

          assert_equal("", active)
        end


        ## start

        def test_start
          job('job')

          Time.set(Time.local(2003, 'mar', 23, 12, 01))

          start_message = start 'job'
          assert_equal("Job 'job' started at 12:01 PM on 02003/03/23.",
                       start_message)
          assert_equal(true, @session.running?('job'))

          job('job/subjob')
          Time.set(Time.local(2003, 'mar', 23, 13, 01))
          start_message = start( 'job/subjob')
          assert_message("Starting another job first pauses 'job'.
                          Job 'job/subjob' started at 01:01 PM on 02003/03/23.",
                         start_message)
          assert_equal(true, @session.running?('job/subjob'))
          assert_equal(false, @session.running?('job'))
          assert_equal(true, @session.paused?('job'))

          Time.set(Time.local(2003, 'mar', 23, 14, 01))
          start_message = start 'job'
          assert_message("Starting another job first pauses 'job/subjob'.
                          Job 'job' resumed at 02:01 PM on 02003/03/23.",
                         start_message)
          assert_equal(true, @session.running?('job'))
          assert_equal(false, @session.running?('job/subjob'))
          assert_equal(true, @session.paused?('job/subjob'))
        end

        # This really represents a test that exceptions from the session
        # facade are handled correctly. Other classes' tests are responsible for
        # checking that the right exceptions are thrown.
        def test_start_started_job
          job 'job'
          start 'job'
          start_message = start 'job'
          assert_message("Timeclock tried to start job 'job'.
                        But 'job' is already started.",
                         start_message)
        end

        def test_quick_start  # Start without job argument
          paused_job = job('will be paused')
          alternate = job('alternate')

          # Start with nothing paused.
          error_message = "Timeclock tried to resume the job you just paused.
                           But you didn't just pause a job.
                           'start' with no argument must follow 'pause' or 'pause_day'."
          assert_message(error_message, start)

          # start with something paused
          start 'will be paused'
          pause

          assert_match(/Job 'will be paused' resumed at/, start)
          assert_equal(true, @session.running?('will be paused'))

          # repeating start
          assert_message(error_message, start)
          assert_equal(true, @session.running?('will be paused'))

          # repeating start when previous start given a name.
          pause
          start 'alternate'
          assert_message(error_message, start)
          assert_equal(true, @session.running?('alternate'))
          assert_equal(true, @session.paused?('will be paused'))

          # A failing start does not make timeclock forget the paused job.
          pause
          start 'mumble'
          assert_match(/Job 'alternate' resumed at/, start)
          assert_equal(true, @session.running?('alternate'))
          assert_equal(true, @session.paused?('will be paused'))


          # intervening stop
          pause
          stop 'will be paused'
          assert_message(error_message, start)
          assert_equal(true, @session.paused?('alternate'))
          assert_equal(true, @session.stopped?('will be paused'))

          # But the stop has to succeed.
          start 'alternate'
          pause
          stop 'foobar'
          assert_match(/Job 'alternate' resumed at/, start)
          assert_equal(true, @session.running?('alternate'))
          assert_equal(true, @session.stopped?('will be paused'))

          # The mechanism is the same for all commands, so not all are
          # tested. But let's check that innocuous (non-active-job-changing)
          # commands don't prevent quick starts.

          start 'will be paused'
          pause
          this_month
          assert_match(/Job 'will be paused' resumed at/, start)
          assert_equal(true, @session.running?('will be paused'))
          assert_equal(true, @session.paused?('alternate'))

          # pause_day works like pause
          stop 'will be paused'
          stop 'alternate'
          
          job 'misc'
          background 'misc'
          start_day
          pause_day
          assert_match(/Job 'misc' resumed at/, start)
          assert_equal(true, @session.running?('misc'))

          # Also works when it's not the background job that's paused.
          start 'alternate'
          pause_day
          assert_match(/Job 'alternate' resumed at/, start)
          assert_equal(true, @session.running?('alternate'))
          assert_equal(true, @session.paused?('misc'))
        end


        def test_start_may_take_time_argument
          pauser = job('will be paused')
          background = job('background')
          background 'background'

          origin = Time.now
          Time.set(Time.local(origin.year, origin.month, origin.day, 9))

          paused_mark = Time.now
          start 'will be paused'
          Time.advance(1.hour)

          background_mark = time_from('9:06 am')
          at '9:06 am' do start 'background' end

          Time.advance(6.minutes)  # 54 from above, add 6 - for variety

          stop_message = stop 'background'
          assert_message(stopped(background_mark, 1.hour, 'background'),
                         stop_message)

          stop_message = stop 'will be paused'
          assert_message(stopped(paused_mark, 6.minutes, 'will be paused'),
                         stop_message)
        end

        def test_quick_start_rejects_time_argument
          job 'j'
          start 'j'
          pause
          assert_message("Timeclock tried to start job '8:13 AM'.
                          But there is no job named '8:13 AM'.",
                         start('8:13 AM'))
        end

        ## start_day

        def test_start_day
          # Starts the background job.
          job 'any old job'
          job 'the background job'
          background 'the background job'

          Time.set(Time.local(2004, 'jan', 13, 8, 13))
          message = start_day
          expected = "Job 'the background job' started at 08:13 AM on 02004/01/13."
          assert_message(expected, message)
          assert_equal(true, @session.running?('the background job'))
        end

        def test_start_day_already_started
          job 'background'
          background 'background'

          start 'background'

          error_message =
            "Timeclock tried to start the day.
             But there are already active jobs, ones that were started earlier
             and never stopped.
             Use the 'active' command to see active jobs.
             You can use the 'stop_day' command to stop them.
             If you want to stop them as of a particular time, give that time
             as an argument to 'stop_day'."

          actual_message = start_day
          assert_message(error_message, actual_message)

          # Also get an error if the active job is another job, and even if
          # it's paused.
          stop 'background'
          job 'timeclock'
          start 'timeclock'
          pause 

          actual_message = start_day
          assert_message(error_message, actual_message)
        end

        def test_start_day_without_background_job
          job 'no background'

          error_message = 
            "Timeclock tried to start the day.
           That meant starting a background job.
           But there is no background job.
           You can make an existing job a background job with
           the 'background' command."
          actual_message = start_day
          assert_message(error_message, actual_message)
        end

        def test_start_day_obeys_at
          job 'j'
          background 'j'

          Time.set(Time.local(2002, 12, 1, 10))
          
          # Rats. It's 10 a.m. and I've been working since 9.
          mark = Time.local(2002, 12, 1, 9)
          at "2002/12/01 9:00 am" do start_day end

          stop_message = stop 'j'
          expected = "Stopped 'j'.
                      (Note that 'j' is the background job.
                      It won't resume the next time you stop or pause a running job.)
                      #{resulting_rec(mark, 1.hour, 'j')}"
          assert_message(expected, stop_message)
        end

        ## pause
        
        def test_pause
          job('a job')
          Time.set(Time.local(2003, 'mar', 13, 19, 31))

          start 'a job'
          assert_equal(true, @session.running?('a job'))

          pause_message = pause
          assert_equal("Paused 'a job' at 07:31 PM on 02003/03/13.",
                       pause_message)
          assert_equal(true, @session.paused?('a job'))
        end

        # This really represents a test that exceptions from the session
        # facade are handled correctly. Other classes' tests are responsible for
        # checking that the right exceptions are thrown.
        def test_pause_errors
          job 'job'
          pause_message = pause
          assert_message("Timeclock tried to pause the running job.
                          But no job is running.",
                         pause_message)
        end


        def test_pause_obeys_at
          job = job('long paused job')
          background = job('background')
          background 'background'

          origin = Time.now
          Time.set(Time.local(origin.year, origin.month, origin.day, 9))
          mark = Time.now

          start_day
          start 'long paused job'   # pauses background
          Time.advance(1.hour)

          # Pause the long paused job back in time. The remaining time
          # will accrue to the background job.
          at "9:06 am" do pause end

          stop_message = stop 'background'
          expected = "Stopped 'background'.
                      (Note that 'background' is the background job.
                      It won't resume the next time you stop or pause a running job.)
                      #{resulting_rec(mark, 54.minutes, 'background')}"
          assert_message(expected, stop_message)

          stop_message = stop 'long paused job'
          assert_message(stopped(mark, 6.minutes, 'long paused job'),
                         stop_message)
        end

        ## pause_day


        def test_pause_day
          # Simple case: one job running that's paused.
          job 'only job'

          Time.set(Time.local(2010, 'aug', 23, 10, 33))
          start 'only job'
          
          pause_day_message = pause_day
          expected = "Paused 'only job' at 10:33 AM on 02010/08/23."
          assert_equal(expected, pause_day_message)

          # It's more complicated when there's a background job - pausing
          # a running job will start the background job, which must be paused.

          job 'background'
          background 'background'
          start 'background'
          start 'only job'

          pause_day_message = at "23-aug-2010 11:13 pm" do pause_day end
          expected = "Paused 'only job' at 11:13 PM on 02010/08/23."
          assert_equal(expected, pause_day_message)

        end

        def test_pause_day_errors
          pause_day_message = pause_day
          assert_message("Timeclock tried to pause the running job without resuming the background job.
                          But no job is running.",
                         pause_day_message)
        end


        ## stop
        def test_stop
          job 'j'
          Time.set(Time.local(2003, 'jul', 3, 23, 31))
          
          start 'j'
          assert_equal(true, @session.running?('j'))

          job 'j/k'
          Time.advance 1.hour
          mark = Time.now
          start 'j/k'
          assert_equal(true, @session.running?('j/k'))
          assert_equal(true, @session.paused?('j'))

          Time.advance 1.hour
          stop_message = stop 'j/k'
          assert_message(stopped(mark, 1.hour, 'j/k'), stop_message)
          assert_equal(false, @session.running?('j/k'))
          assert_equal(false, @session.paused?('j/k'))
          assert_equal(true, @session.paused?('j'))

          stop('j')
          assert_equal(false, @session.running?('j/k'))
          assert_equal(false, @session.paused?('j/k'))
          assert_equal(false, @session.running?('j'))
          assert_equal(false, @session.paused?('j'))
        end

        def test_stop_may_take_time_argument
          job('j')

          # Rats, I let the clock run too long. Stop an hour ago.
          origin = Time.now
          Time.set(Time.local(origin.year, origin.month, origin.day, 12, 13))
          mark = Time.now

          start 'j'

          Time.advance(1.hour)

          stop_message = at "12:19 pm" do stop('j') end
          assert_message(stopped(mark, 6.minutes, 'j'), stop_message)

          # Double rats! I let the clock run over night!
          start_time = Time.local(origin.year, origin.month, origin.day, 16, 00)
          Time.set(start_time)
          start 'j'
          Time.set(start_time + 16.hours)
          
          #          stop_message = stop('j', "#{origin.year}/#{origin.month}/#{origin.day} 17:00")

          stop_date = "#{origin.year}/#{origin.month}/#{origin.day}"
          stop_message = at("#{stop_date} 17:00") {
            stop 'j'
          }
          assert_message(stopped(start_time, 1.hour, 'j'),
                         stop_message)

          # However, it's more convenient to use a keyword.
          # Including more convenient for testing.

          start_time = Time.local(2001, 12, 1, 16, 30)
          Time.set(start_time)
          job 'j/k' # variety
          start 'j/k'
          Time.set(start_time + 16.hours)
          stop_message = at "yesterday 5:00 pm" do stop 'j/k' end
          assert_message(stopped(start_time, 30.minutes, 'j/k'),
                         stop_message)
        end

        # This really represents a test that exceptions from the session
        # facade are handled correctly. Other classes' tests are responsible for
        # checking that the right exceptions are thrown.
        def test_stop_stopped_job
          job 'job'
          assert_message("Timeclock tried to stop job 'job'.
                          But 'job' is already stopped.",
                         stop('job'))
        end

        def test_quick_stop
          job 'ex-bug'

          Time.set(Time.local(1992, "feb", 2, 9))
          mark = Time.now

          start 'ex-bug'
          Time.advance 1.hour

          stop_message=stop
          assert_message(stopped(mark, 1.hour, 'ex-bug'), stop_message)
          assert_equal(true, @session.stopped?('ex-bug'))

          # Stopping without a running job
          start 'ex-bug'
          pause
          stop_message = stop

          expected = "Timeclock tried to stop the running job.
                      But no job is running."
          assert_message(expected, stop_message)
          assert_equal(true, @session.paused?('ex-bug'))

          # Just to be sure, check that quick-stopping a job activates
          # a background job.
          stop_day   # Can't start background job unless there's a clean slate.
          
          job 'background'
          background 'background'
          start_day

          mark = Time.now
          start 'ex-bug'
          Time.advance 1.hour

          stop_message = stop
          assert_message(lines(stopped(mark, 1.hour, 'ex-bug'),
                               resumed_background('background')),
                         stop_message)
          assert_equal(true, @session.stopped?('ex-bug'))
          assert_equal(true, @session.running?('background'))
        end

        def test_quick_stop_obeys_at
          job 'job'
          at "3:00 pm" do start 'job' end
          at "4:00 pm" do stop end

          assert_equal(1.hour, @session.records[0].time_accumulated)
        end

        
        ## stop_day

        def test_stop_day
          job 'first-job'
          job 'background'
          job 'second-job'
          job 'unstarted'

          Time.set(Time.now)
          mark = Time.now
          
          start 'first-job'

          Time.advance(6.minutes)
          start 'background'

          Time.advance(12.minutes)
          start 'second-job'

          Time.advance(30.minutes)
          stop_day_message = stop_day

          expected = lines(".Added these records:",
                           record_list(48.minutes,
                                       [mark,             6.minutes, 'first-job'],
                                       [mark+6.minutes , 12.minutes, 'background'],
                                       [mark+18.minutes, 30.minutes, 'second-job']))
          assert_message(expected, stop_day_message)

          stop_day_message = stop_day
          expected = "Everything is already stopped."
          assert_equal(expected, stop_day_message)

          # To wrap up, check that we can delete a record. This checks that
          # the new records are properly wired into the display mechanism.
          forget 2
          records_message = records
          expected = record_list(36.minutes,
                                 [mark           ,  6.minutes, 'first-job'],
                                 [mark+18.minutes, 30.minutes, 'second-job'])
          assert_message(expected, records_message)
        end


        ## The at command.
        def test_normal_use_of_at
          job 'misc'
          job 'timeclock'
          job 'stqe'
          background 'misc'

          Time.set(Time.local(2003, 2, 13, 9, 0))
                                  misc_mark = Time.now
          start_day

          Time.set(Time.local(2003, 2, 13, 15, 0))
                                  timeclock_mark = Time.now
          start 'timeclock'

          Time.set(Time.local(2003, 2, 13, 16, 0))
                                  # here, for reference, is the state.
                                  assert_message(
                                    record_list(7.hours,
                                       [misc_mark, 6.hours, 'misc', 'paused'],
                                       [timeclock_mark, 1.hour, 'timeclock', 'running']),
                                    records)

                                  stqe_mark = Time.local(2003, 2, 13, 15, 30)
          
          at "3:30 pm" do start 'stqe' end
                                  assert_message(
                                    record_list(7.hours,
                                       [misc_mark,  6.hours, 'misc', 'paused'],
                                       [timeclock_mark, 30.minutes, 'timeclock', 'paused'],
                                       [stqe_mark, 30.minutes, 'stqe', 'running']),
                                    records)

          # Next day
          Time.set(Time.local(2003, 2, 14, 8, 0))
                                  # state of things, for reference.
                                  assert_message(
                                    record_list(23.hours,
                                       [misc_mark,  6.hours, 'misc', 'paused'],
                                       [timeclock_mark, 30.minutes, 'timeclock', 'paused'],
                                       [stqe_mark, 16.hours + 30.minutes, 'stqe', 'running']),
                                    records)

          at "5:00 PM yesterday " do stop_day end
                                  assert_message(
                                    record_list(8.hours,
                                       [misc_mark, 6.hours, 'misc'],
                                       [timeclock_mark, 30.minutes, 'timeclock'],
                                       [stqe_mark, 90.minutes, 'stqe']),
                                    records)

                                  # assert there are no running jobs.
                                  assert_equal(0, @session.active_records.length)

          ## Oops, I actually stopped at 6 yesterday.
          undo
                                  assert_message(
                                    record_list(23.hours,
                                       [misc_mark,  6.hours, 'misc', 'paused'],
                                       [timeclock_mark, 30.minutes, 'timeclock', 'paused'],
                                       [stqe_mark, 16.hours + 30.minutes, 'stqe', 'running']),
                                    records)

          at "6:00 PM yesterday " do stop_day end
                                  assert_message(
                                    record_list(9.hours,
                                       [misc_mark, 6.hours, 'misc'],
                                       [timeclock_mark, 30.minutes, 'timeclock'],
                                       [stqe_mark, 150.minutes, 'stqe']),
                                    records)

                                  # assert there are no running jobs.
                                  assert_equal(0, @session.active_records.length)

        end

        def test_at_modifies_time
          actual_time = Time.set(Time.local(1999, 1, 1, 1))

          # Note that the result of 'at', like the results of all
          # interface commands, is a string - even if we use something
          # that doesn't 'naturally' return a string.

          desired_time = nil
          at "2:12 pm" do
            desired_time = Action.new(nil,nil,nil,nil).desired_time
          end
          assert_equal(Time.local(1999, 1, 1, 14, 12), desired_time)

          # The effect is not "sticky".
          assert_equal(actual_time, Action.new(nil,nil,nil,nil).desired_time)
        end

        def test_at_with_non_or_multiple_commands
          job 'a job'
          job 'second'
          
          # Notice that only the results of timeclock commands are printed
          Time.set(Time.local(1999, 1, 2))
          fake_start_time = Time.local(1999, 1, 1, 14, 13)
          result = at "2:13 pm yesterday" do
            start 'a job'
            "the value of a non-command is ignored"
          end

          assert_message("Job 'a job' started at 02:13 PM on 01999/01/01.",
                         result)

          # That's an artifact of the way that the results of all nested
          # commands are printed, not just the last one (as you'd expect
          # from a Ruby block).

          result = at "3:13 pm yesterday" do
            stop 'a job'
            start 'second'
          end

          # I'm spelling out the result to point out that the time
          # displayed is relative to the real current time, not the
          # time set by the 'at' command.
          assert_message(lines(".Stopped 'a job'.",
                               ".Here is the resulting record:",
                               ".   1:  1.00 hour  from  2:13 PM yesterday on a job",
                               ".Job 'second' started at 03:13 PM on 01999/01/01."),
                         result)
        end

        def test_at_grotesque_nesting
          job 'first'
          job 'second'
          Time.set(Time.local(2003, 12, 2, 12))

          result = at "yesterday 8:00 am" do
            start 'first'
            at "7:00 am" do # note still relative to true time.
              start 'second'
            end
          end

          assert_message(lines("Job 'first' started at 08:00 AM on 02003/12/01.",
                               "Starting another job first pauses 'first'.",
                               "Job 'second' started at 07:00 AM on 02003/12/02."),
                         result)

          # Let's be sure that the nested times are handled right.
          result = stop_day
          first_mark = Time.local(2003, 12, 1, 8)
          second_mark = Time.local(2003, 12, 2, 7)
          assert_message(lines("Added these records:",
                               record_list(28.hours, 
                                           [first_mark, 23.hours, 'first'],
                                           [second_mark, 5.hours, 'second'])),
                         result)
        end
                         
          

        def test_at_with_error
          actual_time = Time.set(Time.local(2003, 1, 1, 1))
          result = at "2;12 pm" do flunk end
          assert_message(lines("Timeclock tried to set the clock for commands within do...end.",
                               time_error('2;12 pm')),
                         result)
        end

        def test_at_works_twice
          job 'first'
          job 'second'

          Time.set(Time.local(2003, 2, 16, 9))
          first_mark = Time.local(2003, 2, 16, 10)
          at "2003/2/16 10:00 a.m." do start 'first' end

          second_mark = Time.set(Time.local(2003, 2, 16, 11))
          start 'second'

          at "1:30 pm" do stop 'second' end
          at "3:00 pm" do start 'first' end

          Time.set(Time.local(2003, 2, 16, 16))
          stop 'first'


          assert_message(record_list(4.hours + 30.minutes,
                                     [first_mark, 2.hours, 'first'],
                                     [second_mark, 2.hours+30.minutes, 'second']),
                         records)
        end

        def test_at_passes_through_all_command_results
          job 'only'
          background 'only'

          result = at "1999/3/3 10:03 p.m." do start_day end
          assert_message("Job 'only' started at 10:03 PM on 01999/03/03.",
                         result)

          assert_equal(:start_background_job, @session.last_command.name)
          assert_equal('only', @session.last_value.name)
          assert_equal(:started, @session.last_change_log.only.name)
        end

      end
    end
  end
end
