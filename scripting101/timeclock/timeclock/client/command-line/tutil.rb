require 'timeclock/marshalled/include-all'
require 'timeclock/client/command-line/Interface'
require 'timeclock/util/RichlyCalledWrapper'
require 'timeclock/util/RichlyCallingWrapper'
require 'timeclock/util/Time'
require 'timeclock/client/tutil'

### IMPORTANT. Most of these methods are used to reduce the amount of
### editing needed when changing parts of the output. However, it's
### important to check whether a change makes sense in all the
### contexts. So here's what to do: when thinking of a change to one
### of these methods, break it in the current version, and inspect the
### actual output from the app before the change. Imagine the
### changes. OK in all cases? Then make the change.

module Timeclock
  module Client
    module CommandLine

      class InterfaceTestCase < ClientTestCase
        include Interface
        include FriendlyTimes

        def setup
          @session = RichlyCallingWrapper.new(
                       RichlyCalledWrapper.new(
                         Server::Session.new("command line commands tests")))
          Interface.attach_to_session(@session)
          Time.use_system_time
        end

        def teardown
          Time.use_system_time
          @session.forget_everything
          Interface.disengage
        end

        

        # About records

        # What a record is supposed to look like, printed.
        # Record printing is tested below. This is for the use of
        # tests that generate records but are mainly testing something else.
        # In the caller, the time argument is conventionally a variable
        # named 'mark', as in "mark an important event for later use".
        def rec(time, elapsed, job_fullname, state="")
          pretty = PrettyTimes.columnar
          if state != ""
            state = " (#{state})"
          end
          sprintf("%s from %s on %s%s",
                  pretty.hours(elapsed),
                  pretty.date_time(time),
                  job_fullname, state)
        end

        def numbered_rec(number, time, elapsed, job_fullname, state = "")
          ".   #{number}: #{rec(time, elapsed, job_fullname, state)}"
        end


        # Record manipulations

        def forgot_record_re(jobname)
          Regexp.new("Forgot this record.*on #{jobname}", Regexp::MULTILINE)
        end

        def forgot_record(start, elapsed, job)
          "Forgot this record: #{rec(start, elapsed, job)}"
        end

        def added_record(start, elapsed, job)
          "Added this record: " + rec(start, elapsed, job)
        end

        def changed_accumulated_time(start, elapsed, job, state="")
          lines("The record's accumulated time has changed:",
                rec(start, elapsed, job, state))
        end

        def resulting_rec(time, elapsed, job_fullname)
          lines(".Here is the resulting record:",
                numbered_rec(1, time, elapsed, job_fullname))
        end

        def put_back_rec(time, elapsed, job_fullname)
          "Put back this record: #{rec(time, elapsed, job_fullname)}"
        end

        def put_back_rec_re
          /Put back this record/
        end

        def record_list_no_total(expected)
          result = []
          expected.each_index { | index |
            state = expected[index][3]
            state = "" if state.nil?
              
            result << numbered_rec(index+1,
                                   expected[index][0],  # time
                                   expected[index][1],  # elapsed
                                   expected[index][2],  # jobname
                                   state)
          }
          result
        end

        def record_list(total, *expected)
          result = record_list_no_total(expected)
          if expected.length != 1
            result << ""
            result << "Total: #{PrettyTimes.columnar.hours(total)}"
          end
          lines(result)
        end

        # Job manipulations

        def forgot_job(job)
          "Job '#{job}' no longer exists.
           Its records (if any) still do."
        end

        def removed_job(job_fullname)
          "Job '#{job_fullname}' has been removed."
        end

        def no_background_job_re
          /But there is no background job/m
        end

        def no_job_re(job_fullname)
          Regexp.new("no job named '#{job_fullname}'")
        end

        def no_subjob_re(job_fullname, subjob_fullname)
          Regexp.new("'#{job_fullname}' has no subjob named '#{subjob_fullname}'")
        end

        def added_back_job(job_fullname)
          "Added back '#{job_fullname}'."
        end

        def added_back_job_tree(job_fullname)
          "Added back '#{job_fullname}' and all its subjobs."
        end

        def again_background(job_fullname)
          "Job '#{job_fullname}' is once again the background job."
        end
        
        # Paused job manipulations

        def paused(job_fullname, mark)
          pretty = PrettyTimes.columnar
          "Paused '#{job_fullname}' at #{pretty.hhmm(mark)} on #{pretty.date(mark)}."
        end

        def paused_re(job_fullname)
          Regexp.new("Paused '#{job_fullname}'")
        end

        def undid_pause(time, elapsed, job_fullname, state)
          ".Restarted '#{job_fullname}' and resumed this record:
           .#{rec(time, elapsed, job_fullname, state)}"
        end

        def undid_resuming_action(time, elapsed, job_fullname)
          
          ".'#{job_fullname}' is no longer resumed. It's back to this:
           .#{rec(time, elapsed, job_fullname, 'paused')}"
        end

        # Starting and resuming jobs manipulations
        def resumed_background(job_fullname)
          "Resuming the background job '#{job_fullname}'."
        end

        def resumed_background_re(job_fullname)
          Regexp.new("Resuming the background job '#{job_fullname}'.")
        end

        def resumed_re(job_fullname)
          Regexp.new("Job '#{job_fullname}' resumed", Regexp::MULTILINE)
        end
        
        def started_re(job_fullname)
          Regexp.new("Job '#{job_fullname}' started", Regexp::MULTILINE)
        end

        def undid_first_start(time, elapsed, job_fullname)
          ".Now that '#{job_fullname}' wasn't started, this record has been forgotten:
           .#{rec(time, elapsed, job_fullname, 'running')}
           .That record's elapsed time is now recorded nowhere."
        end

        def undid_first_start_quickly(job_fullname)
          "Job '#{job_fullname}' is no longer running. No job is."
        end

        def undid_restart(restart_time, job_fullname)
          ".Now that '#{job_fullname}' wasn't resumed at #{restart_time},
           .the time between then and now is recorded nowhere."
        end

        def undid_restart_quickly(job_fullname)
          "Job '#{job_fullname}' is once again paused."
        end
          
        def undid_pausing_start(elapsed, undid_name, previous_name, tag)
          elapsed_hours = PrettyTimes.tight.hours(elapsed)
          "Now that '#{undid_name}' wasn't #{tag}, its accumulated time (#{elapsed_hours})
           has been given to the job '#{previous_name}', which is now running."
        end

        def undid_pausing_start_quickly(previous_name)
          "Job '#{previous_name}' is once again running."
        end


        def bad_quick_start_re
          /you didn't just pause a job/
        end
        
        # Stopped job manipulations

        def stopped(time, elapsed, job_fullname)
          "Stopped '#{job_fullname}'.
           Here is the resulting record:
           #{numbered_rec(1, time, elapsed, job_fullname)}"
        end

        def stopped_re(job_fullname)
          Regexp.new("Stopped '#{job_fullname}'")
        end

        def stop_error_re(job_fullname)
          Regexp.new("But '#{job_fullname}' is already stopped")
        end

        def stopped_day(*expected)
          lines("Added these records:",
                record_list_no_total(expected))
        end

        def stop_day_error_re
          /Everything is already stopped/
        end

        def undid_stop(time, elapsed, job_fullname, state)
          ".Undid the stopping of '#{job_fullname}' and reinstalled this record:
            .#{rec(time, elapsed, job_fullname, state)}"
        end

        def undid_stop_re(job_fullname)
          Regexp.new("Undid the stopping of '#{job_fullname}'")
        end

        # Time manipulations

        def time_error(string)
          "That meant interpreting '#{string}' as a time.
           But '#{string}' doesn't seem to be a date or a time."
        end


        
        # Command: undo

        def undid_prefix(command)
          "Undid the #{command} command. To be specific:"
        end

        def undid_re(command)
          Regexp.new("Undid the #{command} command")
        end

        def nothing_to_undo
          "Timeclock tried to undo the last command.
           But there is nothing to undo."
        end

        def undo_with_no_op_command(command)
          "In this case, the #{command} command did nothing,
           so there is nothing to undo."
        end

      end
    end
  end
end
