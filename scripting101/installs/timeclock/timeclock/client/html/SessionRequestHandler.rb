require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/LoginPageSketch'
require 'timeclock/client/html/MainPageSketch'
require 'timeclock/client/html/FirstJobCreationPageSketch'
require 'timeclock/client/html/BadRequestPageSketch'
require 'timeclock/server/UserManager'
require 'timeclock/util/RichlyCallingWrapper'
require 'timeclock/client/ActionOrchestrator'

module Timeclock
  module Client
    module Html

      class SessionRequestHandler

        attr_reader :user_name, :session

        def initialize(session, user_name)
          @user_name = user_name
          @session = session
          @action_orchestrator = ActionOrchestrator.only_instance(@session)
        end
        
        def checked_value(arg_name, http_request)
          arg_value = http_request.args[arg_name]
          if arg_value.nil?
            throw :problem, BadRequestPageSketch.missing_arg(arg_name)
          end

          case arg_name
          when 'name'
            if arg_value == ''
              throw :problem,
                    sketch("Sorry, but you have to give a job name.", :error)
            end
          end
          arg_value
        end

        def attempt(http_request, command, *arg_names)
          args = arg_names.collect { | name |
            checked_value(name, http_request)
          }
          @action_orchestrator.attempt(command, args)
          @action_orchestrator.describe_result_for_html
        end


        def handle(http_request)
          # Some forms have multiple buttons. This selects among them.
          handle_multi_buttons = proc { |description, *actions|
            match = actions.find { | name | http_request.has_arg?(name.to_s) }
            if match
              sketch(attempt(http_request, match))
            else
              BadRequestPageSketch.missing_arg(description)
            end
          }

          problem_description = catch(:problem) { 
            case http_request.name
            when 'job'
              job_result = attempt(http_request, :job, 'name')
              if http_request.has_arg?('background')
                background_result = attempt(http_request, :background, 'name')
              end
              sketch(lines(job_result, background_result))
            when 'start'
              result = attempt(http_request, :start, 'name')
              sketch(result)
            when 'start_day'
              result = attempt(http_request, :start_day)
              sketch(result)
            when 'pause_or_stop_day'
              handle_multi_buttons.call("pause_day or stop_day",
                                        :pause_day, :stop_day)
            when 'pause_or_stop_job'
              handle_multi_buttons.call("pause or quick_stop",
                                        :pause, :quick_stop)
            when 'refresh'
              sketch('')
            else
              BadRequestPageSketch.unknown_request(http_request.name,
                                                   http_request.inspect)
            end
          }
        end


        def sketch(last_result="", result_is_error=false)
          MainPageSketch.new(@user_name, @session,
                             last_result, result_is_error)
        end
      end
    end
  end
end
