# Those actions that mainly affect the ongoing recording of time.

require 'timeclock/client/command-line/ResultDescriberUtils'

module Timeclock
  module Client
    module CommandLine
      public

      ## Active

      class ActiveResultDescriber < ResultDescriber
        def success_strings(action_result, all_describers)
          ars = action_result.value.values
          result = []
          pretty = PrettyTimes.tight

          running = ars.find { | ar | ar.running? } 
          if running
            result << sprintf("'%s' is running, with %s from %s.",
                              running.job.full_name,
                              pretty.hours(running.time_accumulated),
                              pretty.date_time(running.time_started))
            ars.delete running
          end

          unless ars.empty?
            result << "Paused:"
            ars.sort { | ar1, ar2 |
              ar1.job.full_name <=> ar2.job.full_name
            }.each { | ar |
              result << sprintf("'%s', with %s from %s.",
                                ar.job.full_name,
                                pretty.hours(ar.time_accumulated),
                                pretty.date_time(ar.time_started))
            }
          end
          result
        end
      end


      ## start

      class StartResultDescriber < Client::StartResultDescriber
        include ResultDescriberUtils
        
        def undo_success_strings(action_result, all_describers)

          # Either the undone start was the very first one for this job or
          # it was resumed from a pause.
          very_first_start = action_result.change_log.has?(:undid_start)
          if very_first_start
            unstarted = action_result.change_log[:undid_start][:record]
          else
            unstarted =
              action_result.change_log[:restored_resumed_record][:erased]
          end
          

          # Was another job paused when this started?
          start_caused_pause =
            action_result.change_log.has?(:restored_paused_record)
          if start_caused_pause
            formerly_paused = action_result.change_log[:restored_paused_record][:restored_record]
          end

          if     true == very_first_start and  true == start_caused_pause
            either_paused_running_job(unstarted, formerly_paused, "started")
          elsif false == very_first_start and  true == start_caused_pause
            either_paused_running_job(unstarted, formerly_paused, "resumed")
          elsif  true == very_first_start and false == start_caused_pause
            first_start_did_not_pause_running_job(unstarted)
          elsif false == very_first_start and false == start_caused_pause
            restart_did_not_pause_running_job(unstarted)
          end
        end

        private

        def quick_undo?(unstarted)
          PrettyTimes.insignificant_hours(unstarted.most_recent_time_accumulated)
        end

        def either_paused_running_job(unstarted, formerly_paused, tag)
          formerly_name = formerly_paused.job.full_name

          if quick_undo?(unstarted)
            ["Job '#{formerly_name}' is once again running."]
          else
            transferred_hours =
              PrettyTimes.tight.hours(unstarted.most_recent_time_accumulated)
            ["Now that '#{unstarted.job.full_name}' wasn't #{tag}, its accumulated time (#{transferred_hours})",
              "has been given to the job '#{formerly_name}', which is now running."
            ]
          end
        end

        def first_start_did_not_pause_running_job(unstarted)
          name = unstarted.job.full_name
          if quick_undo?(unstarted)
            ["Job '#{name}' is no longer running. No job is."]
          else
            ["Now that '#{name}' wasn't started, this record has been forgotten:",
              RecordStringifier.new(unstarted).summary,
              "That record's elapsed time is now recorded nowhere."
            ]
          end
        end

        def restart_did_not_pause_running_job(unstarted)
          name = unstarted.job.full_name
          if quick_undo?(unstarted)
            ["Job '#{name}' is once again paused."]
          else
            start_time = unstarted.most_recent_time_started
            printable = PrettyTimes.tight.date_time(start_time)
            ["Now that '#{name}' wasn't resumed at #{printable},",
              "the time between then and now is recorded nowhere."
            ]
          end
        end
      end


      ## Quick_start

      class QuickStartResultDescriber < StartResultDescriber
        def attempt_description(*ignored)
          "Timeclock tried to resume the job you just paused."
        end
      end


      ## Start_day

      class StartDayResultDescriber < Client::StartDayResultDescriber

        def advice(complaint_code)
          case complaint_code
          when :start_background_but_jobs_are_active
            "Use the 'active' command to see active jobs.
             You can use the 'stop_day' command to stop them.
             If you want to stop them as of a particular time, give that time
             as an argument to 'stop_day'."
          when :start_background_but_no_background_job
            "You can make an existing job a background job with
             the 'background' command."
          end
        end
      end


      ## Stop

      class StopResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def attempt_description(full_name, *ignored)
          "Timeclock tried to stop job '#{full_name}'."
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
              record = entry[:record]
              @referrables.build_index([record])
              ["Here is the resulting record:",
                referrable_record_listing([record])
              ]
            else
              flunk_unexpected_change(entry)
            end
          }
        end

        def undo_success_strings(action_result, all_describers)
          action_result.change_log.collect { | entry |
            case entry.name
            when :restored_stopped_record
              restored_stopped_record_strings(entry)
            when :forgot_record
              # Redundant information.
            when :restored_resumed_record
              # The background job has been un-resumed
              restored_resumed_record_strings(entry)
            else
              flunk_unexpected_undo_change(entry)
            end
          }
        end
      end
      

      ## Quick_stop

      class QuickStopResultDescriber < StopResultDescriber
        def attempt_description(*ignored)
          "Timeclock tried to stop the running job."
        end
      end


      ## Stop_day

      class StopDayResultDescriber < ResultDescriber
        include ResultDescriberUtils
        def success_strings(action_result, all_describers)
          records = action_result.change_log[:stopped_all_jobs][:records]
          
          if records.empty?
            "Everything is already stopped."
          else
            @referrables.build_index(records)
            ["Added these records:",
              referrable_record_listing(records)
            ]
          end
        end

        def undo_success_strings(action_result, all_describers)
          # puts action_result.change_log.inspect
          stopped = action_result.change_log.matching(:restored_stopped_record)
          stopped.collect { | entry |
            restored_stopped_record_strings(entry)
          }
        end

      end


      ## Pause

      class PauseResultDescriber < Client::PauseResultDescriber
        include ResultDescriberUtils

        def undo_success_strings(action_result, all_describers)
          action_result.change_log.collect { | entry |
            case entry.name
            when :restored_paused_record
              restored_paused_record_strings(entry)
            when :restored_resumed_record
              restored_resumed_record_strings(entry)
            else
              flunk_unexpected_undo_change(entry)
            end
          }
        end
      end

      ## Pause_day

      class PauseDayResultDescriber < PauseResultDescriber
        def attempt_description(*ignored)
          "Timeclock tried to pause the running job without resuming the background job."
        end

        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:paused)
          paused_string(entry)
        end

      end

      ## At
      class AtResultDescriber < ResultDescriber

        def attempt_description(desired_time_string)
          "Timeclock tried to set the clock for commands within do...end."
        end

        def success_strings(action_result, all_describers)
          # At itself contributes nothing to the output. Only the
          # commands nested within its do...end block do.
          []
        end
      end
    end
  end
end
