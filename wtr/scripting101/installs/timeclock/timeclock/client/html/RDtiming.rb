# Those actions that mainly affect the ongoing recording of time.
# They're tested indirectly through tRequestHandler.rb

require 'timeclock/client/ResultDescriberUtils'

module Timeclock
  module Client
    module Html
      public

      ## Active

      class ActiveResultDescriber < ResultDescriber
        # I do not expect that the HTML client will ever display
        # the result of this command, but the class is required by the
        # ResultDescriber framework.
      end


      ## start

      class StartResultDescriber < Client::StartResultDescriber
      end


      ## Quick_start

      class QuickStartResultDescriber < StartResultDescriber
        # I do not expect that the HTML client will ever call
        # this command, but the class is required by the
        # ResultDescriber framework.
      end


      ## Start_day

      class StartDayResultDescriber < Client::StartDayResultDescriber
        def advice(complaint_code)
          flunk("It should be impossible to cause a start-day error.")
        end
      end


      ## Stop

      class StopResultDescriber < ResultDescriber
        # I do not expect that the HTML client will ever call
        # this command, but the class is required by the
        # ResultDescriber framework.
      end
      

      ## Quick_stop

      class QuickStopResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def attempt_description(full_name, *ignored)
          flunk 'failure should be impossible'
        end

        def success_strings(action_result, all_describers)
          action_result.change_log.collect { | entry |
            case entry.name
            when :stopped
              name = entry[:new].job.full_name 
              result = ["Stopped '#{name}'."]
              if entry[:new].potential_restart_volunteer
                result << "(Note that '#{name}' is the background job."
                result << "It won't resume the next time you stop or pause a running job.)"
              end
              result
            when :resumed
              resumed_background_string(entry)
            when :added_finished_record
              accumulated = entry[:record].time_accumulated
              hour_string = PrettyTimes.tight.hours(accumulated)
              "It had accumulated #{hour_string}."
            else
              flunk_unexpected_change(entry)
            end
          }
        end
      end


      ## Stop_day

      class StopDayResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def success_strings(action_result, all_describers)
          stopped_jobs = action_result.change_log.matching(:stopped)
          assert(stopped_jobs.length > 0,
                 "The 'Stop the Day' button shouldn't be availble when there are no jobs running.")

          
          stopped_jobs[0][:at].strftime("Stopped all jobs at #{tight_time_format}.")
        end
      end

      ## Pause

      class PauseResultDescriber < Client::PauseResultDescriber
        def undo_success_strings
          flunk("Undo not implemented for pause yet.")
        end
      end

      ## Pause_day

      class PauseDayResultDescriber < PauseResultDescriber
        def attempt_description(*ignored)
          flunk("It should be impossible to fail at pausing the day.")
        end
        
        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:paused)
          paused_string(entry)
        end
      end

      ## At
      class AtResultDescriber < ResultDescriber
      end
    end
  end
end
