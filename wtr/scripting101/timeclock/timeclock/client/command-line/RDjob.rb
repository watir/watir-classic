# Those actions that deal mainly with jobs.

require 'timeclock/client/ResultDescriber'
require 'timeclock/client/command-line/ResultDescriberUtils'

module Timeclock
  module Client
    module CommandLine

      public

      ## Job

      class JobResultDescriber < Client::JobResultDescriber
      end


      # forget_job

      class ForgetJobResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def attempt_description(full_name, *ignored_rest)
          "Timeclock tried to forget job '#{full_name}'."
        end

        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:forgot_job)
          job = entry[:job]
          base = ["Job '#{job.full_name}' no longer exists.",
            "Its records (if any) still do."]
          unless job.subjobs.empty?
            base << "Note that all of the job's subjobs have been forgotten too."
          end
          base
        end

        def undo_success_strings(action_result, all_describers)
          action_result.change_log.collect { | entry |
            case entry.name
            when :job_created
              job = entry[:job]
              if job.subjobs.empty?
                "Added back '#{entry[:job].full_name}'."
              else
                "Added back '#{entry[:job].full_name}' and all its subjobs."
              end
            when :job_exists
              # ignore - they don't care about that in undoing.
            else
              flunk_unexpected_undo_change(entry)
            end
          }
        end

        def advice(complaint_code)
          case complaint_code
          when :forgetting_active_job
            "Please stop the job before forgetting it."
          end
        end
      end


      ## Background

      class BackgroundResultDescriber < Client::BackgroundResultDescriber
        include ResultDescriberUtils

        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only
          
          case entry.name
          when :first_background
            new_name = entry[:new_background].full_name
            ["'#{new_name}' will now be started by 'start_day'.",
              "Thereafter, it will resume recording time when other jobs pause or stop."
            ]
          when :swapped_background
            swapped_background_strings(entry)
          else
            flunk_unexpected_change(entry)
          end
        end

        def undo_success_strings(action_result, all_describers)
          entry = action_result.change_log.only

          case entry.name
          when :forgot_background
            forgot_background_string(entry)
          when :swapped_background
            swapped_background_strings(entry)
          else
            flunk_unexpected_undo_change(entry)
          end
        end
      end


      ## Forget_background

      class ForgetBackgroundResultDescriber < ResultDescriber
        include ResultDescriberUtils
        def attempt_description(*ignored)
          "Timeclock tried to forget the background job."
        end

        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:forgot_background)
          forgot_background_string(entry)
        end

        def undo_success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:first_background)
          "Job '#{entry[:new_background].full_name}' is once again the background job."
        end
      end

      ## Jobs

      class JobsResultDescriber < ResultDescriber
        include ResultDescriberUtils
        def run
          @session.jobs
        end

        def success_strings(action_result, all_describers)
          printable_job_list = proc { | jobs, prefix, so_far | 
            jobs.values.sort.each { | job |
              job_description = (prefix + job.full_name)
              if job.is_background?
                job_description += "   (the current background job)"
              end
              so_far << job_description
              printable_job_list.call(job.subjobs, "  ", so_far)
            }
            so_far
          }
          
          lines printable_job_list.call(action_result.value, '', [])
        end
      end        
    end
  end
end
