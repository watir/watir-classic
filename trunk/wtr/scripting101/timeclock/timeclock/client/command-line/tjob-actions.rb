require 'timeclock/client/command-line/tutil.rb'

module Timeclock
  module Client
    module CommandLine

      class InterfaceJobActionTests < InterfaceTestCase

        # job
        
        def test_job_and_jobs
          assert_equal("Job 'hello' created.", job('hello'))
          assert_equal("hello", jobs)

          # Duplicates ignored.
          assert_equal("Job 'hello' already exists, so it did not have to be created.",
                       job('hello'))
          assert_equal("hello", jobs)
        end

        def test_background_job_annotation
          job 'hello'
          background 'hello'
          job 'not background'
          
          assert_message("hello   (the current background job)
                          not background", jobs)
        end

        def test_subjob_creation
          assert_equal("Job 'j' created.", job('j'))
          assert_message("Subjob 'j/s' created.
                          Job 'j' already exists, so it did not have to be created.",
                         job('j/s'))
          assert_message(".j
                          .  j/s",
                         jobs)

          # If no job exists, create it before the subjob. Note alphabetical
          # ordering.
          assert_message("Job 'a' created.
                          Subjob 'a/z' created.",
                         job('a/z'))
          assert_message(".a
                          .  a/z
                          .j
                          .  j/s",
                         jobs)

          # Duplicate subjobs are ignored.
          assert_message("Subjob 'a/z' already exists, so it did not have to be created.",
                         job('a/z'))
          assert_message(".a
                          .  a/z
                          .j
                          .  j/s",
                         jobs)
        end

        ## forget_job

        def test_simple_forget_job
          job 'hello'
          message = forget_job 'hello'
          assert_message(forgot_job('hello'), message)

          message = jobs
          assert_message("", message)
        end

        def test_forget_subjob
          job 'retain-j/s'
          message = forget_job 'retain-j/s'
          assert_message(forgot_job('retain-j/s'), message)

          message = jobs
          assert_message("retain-j", message)

          # The same works when the subjobs are created in a separate step.
          job 'upper'
          job "upper/lower"

          message = forget_job 'upper/lower'
          assert_message(forgot_job('upper/lower'), message)

          message = jobs
          assert_message("retain-j
                          upper", message)

        end

        def test_forget_job_with_subjobs
          job 'j/s'
          message = forget_job 'j'
          assert_message(lines(forgot_job('j'),
                               "Note that all of the job's subjobs have been forgotten too."),
                         message)
        end

        def test_forget_job_error
          job 'good'
          message = forget_job 'goo'
          assert_message("Timeclock tried to forget job 'goo'.
                          But there is no job named 'goo'.",
                         message)
        end

        def test_forget_job_does_not_affect_old_records
          job 'forgotten'
          start 'forgotten'
          stop 'forgotten'
          forget_job 'forgotten'

          assert_equal('forgotten', @session.records[0].job.full_name)

          # Moreover, it is OK to restore the same-named job.
          job 'forgotten'
          start 'forgotten'
          stop 'forgotten'
          assert_equal('forgotten', @session.records[0].job.full_name)
          assert_equal('forgotten', @session.records[1].job.full_name)
        end

        def test_forget_job_with_active_records
          # Forgetting a running job could be the same as a finished
          # job. But it's a sufficiently odd thing to do that we warn
          # the user.
          job 'posed'
          start 'posed'
          message = forget_job 'posed'
          assert_message("Timeclock tried to forget job 'posed'.
                          But that job is currently active.
                          Please stop the job before forgetting it.",
                         message)
        end


        ## background

        def test_background_jobs
          job 'default'
          message = background 'default'
          expected = "'default' will now be started by 'start_day'.
                      Thereafter, it will resume recording time when other jobs pause or stop."
          assert_message(expected, message)

          job 'other'

          mark = Time.local(1995, 'feb', 19)
          Time.set(mark)
          start_day

          # Pausing another restarts the default job
          start 'other'
          pause_message = pause
          assert_message(lines(paused('other', mark),
                               resumed_background('default')),
                         pause_message)

          assert_equal(true, @session.running?('default'))

          # Pausing the default job does not restart the other
          pause_message = pause
          assert_equal(paused('default', mark),
                       pause_message)

          assert_equal(true, @session.paused?('other'))

          # Stopping a running job starts the background job.
          start 'default'
          start 'other'
          assert_message(lines(stopped(mark, 0.hours, 'other'),
                               resumed_background('default')),
                         stop('other'))
        end

        def test_switching_background_jobs
          job 'default'
          background 'default'

          job 'new default'
          message = background 'new default'
          expected = "'default' is no longer the background job.
                      It has been replaced by 'new default'.
                      This change will take effect the next time you use 'start_day'.
                      Thereafter, 'new default' will resume recording time when other jobs pause or stop."
          assert_message(expected, message)

          # And did it have an effect?
          start_day
          start 'default'
          message = pause
          assert_match(paused_re('default'), message) # paused right one?
          assert_match(resumed_background_re('new default'), message)
        end

        def test_switching_background_jobs_in_mid_stream
          # Show that the effect really doesn't take place until next day.
          job 'clinics'
          background 'clinics'
          job 'lecture'
          job 'research'

          start_day
          start 'research'

          # Prepare to be doing research tomorrow.
          message = background 'research'
          expected = "'clinics' is no longer the background job.
                      It has been replaced by 'research'.
                      This change will take effect the next time you use 'start_day'.
                      Thereafter, 'research' will resume recording time when other jobs pause or stop."
          assert_message(expected, message)

          background 'research'

          # Doesn't affect today.
          start 'lecture'
          pause
          assert_equal(true, @session.running?('clinics'))

          stop_day

          # Does affect tomorrow.
          start_day
          assert_equal(true, @session.running?('research'))
        end

        def test_background_errors
          assert_message("Timeclock tried to make 'none' a background job.
                          But there is no job named 'none'.",
                         background('none'))

          # Moreover, if we're replacing a background job with an erroneous
          # one, the old one is not affected.
          job 'hello'
          background 'hello'
          assert_equal(true, @session.find_job_named('hello').is_background?)

          message = background 'oopsie'
          assert_message("Timeclock tried to make 'oopsie' a background job.
                          But there is no job named 'oopsie'.",
                         message)
          assert_equal(true, @session.find_job_named('hello').is_background?)
          
        end

        def test_forget_background
          job 'background'
          background 'background'
          message = forget_background
          assert_message("'background' is no longer the background job.
                          The job still exists and can be used in the ordinary way.",
                         message)
          assert_match(no_background_job_re, start_day)

          # What happens if the background job is running?
          background 'background'
          start_day
          message = forget_background
          assert_message("'background' is no longer the background job.
                          Since it is currently in use, the change will take effect after you stop it.
                          Thereafter, the job will still exist and can be used in the ordinary way.",
                         message)
          stop_day
          assert_match(no_background_job_re, start_day)

          # The same is true if it is paused.
          background 'background'
          start_day
          pause

          message = forget_background
          assert_message("'background' is no longer the background job.
                          Since it is currently in use, the change will take effect after you stop it.
                          Thereafter, the job will still exist and can be used in the ordinary way.",
                         message)
          stop 'background'
          assert_match(no_background_job_re, start_day)

          # But note that the message is different if the background
          # job was started as an ordinary job, not via start_day.
          background 'background'
          start 'background'
          message = forget_background
          assert_message("'background' is no longer the background job.
                          The job still exists and can be used in the ordinary way.",
                         message)
          stop 'background'
          assert_match(no_background_job_re, start_day)

        end

        def test_forget_background_errors
          job 'background'
          message = forget_background
          assert_message("Timeclock tried to forget the background job.
                          But there is no background job.",
                         message)
        end
      end
    end
  end
end
