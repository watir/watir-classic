require 'timeclock/client/ResultDescriberUtils'

module Timeclock
  module Client
    class ResultDescriber
      include ResultDescriberUtils

      def initialize(referrables)
        @referrables = referrables
      end

      # Printed when action complains that it can't do as the user asked.
      def attempt_description(*args)
        flunk "Supposedly, #{self.type}#attempt_description isn't needed because the corresponding command always succeeds."
      end

      # The 'server' makes a number of state changes in response to a
      # method call. Those are described in the change log it sends back.
      # This prints the change log in a way useful to the issuer of this
      # command. Although some changes are made in response to several
      # commands (for example, a job may be paused by either 'pause' or
      # 'start'), it's often the case that the change needs to be described
      # differently for each command.
      #
      # The action_result contains the change log and the action that
      # provoked it. all_describers is used if the describer needs to
      # refer to other actions (like their human-friendly name).

      def success_strings(action_result, all_describers)
        flunk("subclass must define success_strings")
      end

      # Advice is printed when the action complained.
      def advice(exception_code)
        []
      end

      def undo_success_strings(action_result, all_describers)
        flunk "How did undo succeed on '#{name_symbol}'? It can't be undone."
      end

    end

    ### Here, we name the various result describers that have common
    ### behaviors in different classes.

    class JobResultDescriber < ResultDescriber
      include ResultDescriberUtils

      def success_strings(action_result, all_describers)
        action_result.change_log.collect { | entry |
          job = entry[:job]
          tag = job.is_subjob? ? 'Subjob' : 'Job'
          case entry.name
          when :job_exists
            "#{tag} '#{job.full_name}' already exists, so it did not have to be created."
          when :job_created
            "#{tag} '#{job.full_name}' created."
          else
            flunk_unexpected_change(entry)
          end
        }
      end

      def undo_success_strings(action_result, all_describers)
        action_result.change_log.collect { | entry |
          case entry.name
          when :forgot_job
            "Job '#{entry[:job].full_name}' has been removed."
          else
            flunk_unexpected_undo_change(entry)
          end
        }
      end
    end


    class StartDayResultDescriber < ResultDescriber
      include ResultDescriberUtils
      
      def attempt_description(*ignored)
        "Timeclock tried to start the day."
      end

      def success_strings(action_result, all_describers)
        entry = action_result.change_log.only(:started)
        started_string(entry)
      end

      def undo_success_strings(action_result, all_describers)
        "No job is active."
      end

      def advice(complaint_code)
        flunk("Subclass must define")
      end
    end


    class PauseResultDescriber < ResultDescriber
      include ResultDescriberUtils
      def attempt_description(*ignored)
        "Timeclock tried to pause the running job."
      end

      def success_strings(action_result, all_describers)
        action_result.change_log.collect { | entry |
          case entry.name
          when :paused
            paused_string(entry)
          when :resumed
            resumed_background_string(entry)
          else
            flunk_unexpected_change(entry)
          end
        }
      end

    end

    class StartResultDescriber < ResultDescriber
      include ResultDescriberUtils
      
      def attempt_description(full_name, *ignored_rest)
        "Timeclock tried to start job '#{full_name}'."
      end

      def success_strings(action_result, all_describers)
        action_result.change_log.collect { | entry |
          case entry.name
          when :started
            started_string(entry)
          when :resumed
            resumed_string(entry)
          when :paused
            "Starting another job first pauses '#{entry[:new].job.full_name}'."
          else
            flunk_unexpected_change(entry)
          end
        }
      end
    end


    class BackgroundResultDescriber < ResultDescriber
      include ResultDescriberUtils

      def attempt_description(full_name, *ignored_rest)
        "Timeclock tried to make '#{full_name}' a background job."
      end

    end



  end
end
