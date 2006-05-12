module Timeclock
  module Client
    module ResultDescriberUtils

        ## The following methods are used to produce strings that
        ## describe state changes. Each change gets a log entry
        ## in a RichResult.
        def started_or_resumed_string(change_tag, at, job)
          at.strftime("Job '#{job}' #{change_tag} at %I:%M %p on 0%Y/%m/%d.")
        end

        def started_string(log_entry)
          started_or_resumed_string('started', log_entry[:at],
                                    log_entry[:new].job.full_name)
        end

        def resumed_string(log_entry)
          started_or_resumed_string('resumed', log_entry[:at],
                                    log_entry[:new].job.full_name)
        end

        def paused_string(log_entry)
          pause_time = log_entry[:at]
          full_name = log_entry[:new].job.full_name
          
          pause_time.strftime("Paused '#{full_name}' at #{tight_time_format}.")
        end

        def tight_time_format  # for strftime
          "%I:%M %p on 0%Y/%m/%d"
        end

        def resumed_background_string(log_entry)
          "Resuming the background job '#{log_entry[:new].job.full_name}'."
        end




        # Assertion wrappers

        def flunk_unexpected_change(log_entry)
          flunk "Unexpected change '#{log_entry.name}' from action '#{@name_symbol}'."
        end

        def flunk_unexpected_undo_change(log_entry)
          flunk "Unexpected change '#{log_entry.name}' when undoing action '#{@name_symbol}'."
        end


    end
  end
end

