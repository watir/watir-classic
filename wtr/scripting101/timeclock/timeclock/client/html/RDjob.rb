# Those actions that deal mainly with jobs.
# They're tested indirectly through tRequestHandler.rb

require 'timeclock/client/ResultDescriber'
require 'timeclock/client/html/ResultDescriberUtils'

module Timeclock
  module Client
    module Html

      public

      ## Job

      class JobResultDescriber < Client::JobResultDescriber
      end


      # forget_job

      class ForgetJobResultDescriber < ResultDescriber
      end


      ## Background

      class BackgroundResultDescriber < Client::BackgroundResultDescriber

        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only
          
          case entry.name
          when :first_background
            new_name = entry[:new_background].full_name
            [%Q{'#{new_name}' will be started when you press the "Start the Day" button.}
            ]
          when :swapped_background
            flunk("Can't swap background jobs yet in HTML client.")
          else
            flunk_unexpected_change(entry)
          end
        end
      end


      ## Forget_background

      class ForgetBackgroundResultDescriber < ResultDescriber
      end

      ## Jobs

      class JobsResultDescriber < ResultDescriber
        # I do not expect that the HTML client will ever display
        # the result of this command, but the class is required by the
        # ResultDescriber framework.
      end        
    end
  end
end
