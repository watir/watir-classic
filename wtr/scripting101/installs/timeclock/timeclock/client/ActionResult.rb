module Timeclock
  module Client

    ## NormalActionResult

    class NormalActionResult
      attr_reader :action, :value, :change_log

      def initialize(action, session)
        @action = action
        @value = session.last_value
        @change_log = session.last_change_log
      end

      def describe(result_describers)
        describer = result_describers[@action.name_symbol]
        lines(describer.success_strings(self, result_describers))
      end
    end



    ## ErrorActionResult

    class ErrorActionResult

      def initialize(action, args, steps, exception)
        @action = action
        @args = args
        @steps = steps
        @exception = exception
      end

      def describe(result_describers)
        describer = result_describers[@action.name_symbol]
        lines(describer.attempt_description(*@args),
              relevant_steps(@steps, @exception.code),
              complaint(@exception),
              describer.advice(@exception.code)).without_left_whitespace
      end

      def relevant_steps(steps, exception_code)
        steps.collect { | step |
          relevant_error_codes = Steps[step.name].relevant_error_codes
          if relevant_error_codes.include?(exception_code)
            Steps[step.name].describer.call(step.args)
          end
        }
      end

      def complaint(exception)
        Errors.new.send(exception.code, *exception.args)
      end

      Steps = Hash.new
      
      def self.initialize_steps
        struct = Struct.new(:describer, :relevant_error_codes)
        
        Steps[:parse_time] = struct.new(
                                        proc { | time, *rest |
                                          "That meant interpreting '#{time}' as a time."
                                        },
                                        [:parse_time_format]
                                        )

        Steps[:start_background_job] = struct.new(
                                                  proc { | *rest |
                                                    "That meant starting a background job."
                                                  },
                                                  [:start_background_but_no_background_job]
                                                  )
        
      end
      initialize_steps

      class Errors
        def parse_time_format(time_string)
          "But '#{time_string}' doesn't seem to be a date or a time."
        end
        def job_already_stopped(full_name)
          "But '#{full_name}' is already stopped."
        end
        def job_already_started(full_name)
          "But '#{full_name}' is already started."
        end
        def no_job_to_pause 
          "But no job is running."
        end
        def no_job_to_stop 
          "But no job is running."
        end
        def start_background_but_jobs_are_active 
          "But there are already active jobs, ones that were started earlier
           and never stopped."
        end
        def start_background_but_no_background_job 
          "But there is no background job."
        end
        def forget_background_but_no_background_job 
          "But there is no background job."
        end
        def no_such_job(job_name) 
          "But there is no job named '#{job_name}'."
        end
        def no_such_subjob(job_name, subjob_name) 
          "But '#{job_name}' has no subjob named '#{subjob_name}'."
        end
        def no_starting_time  
          "But no starting time was given." 
        end
        def no_job  
          "But no job was given."
        end
        def no_accumulated_time  
          "But no accumulated time was given."
        end
        def no_job_recently_paused  
          "But you didn't just pause a job.
           'start' with no argument must follow 'pause' or 'pause_day'."
        end
        def nothing_to_undo  
          "But there is nothing to undo."
        end
        def forgetting_active_job  
          "But that job is currently active."
        end
        def invalid_record_numbers(invalid_numbers)
          if invalid_numbers.length == 1
            "But no record matches #{invalid_numbers[0]}."
          else
            "But these numbers do not match any records: #{invalid_numbers.join(', ')}."
          end
        end
      end
    end

  end
end
