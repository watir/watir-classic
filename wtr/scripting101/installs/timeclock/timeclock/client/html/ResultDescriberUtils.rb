module Timeclock
  module Client
    module Html
      module ResultDescriberUtils
        def stopped_string(log_entry)
          # Should look something like this:
          # pause_time = log_entry[:at]
          # full_name = log_entry[:new].job.full_name
          
          # pause_time.strftime("Stopped '#{full_name}' at #{tight_time_format}.")
        end
      end
    end
  end
end
