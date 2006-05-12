require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/LoginPageSketch'
require 'timeclock/client/html/MainPageSketch'
require 'timeclock/client/html/FirstJobCreationPageSketch'
require 'timeclock/client/html/BadRequestPageSketch'
require 'timeclock/server/UserManager'
require 'timeclock/util/RichlyCallingWrapper'
require 'timeclock/client/html/SessionRequestHandler'

module Timeclock
  module Client
    module Html

      class RequestHandler

        attr_reader :user_manager

        def initialize(user_manager)
          @user_manager = user_manager
          @session_handlers_by_id = {}
        end


        def find_user_session_handler(name)
          @session_handlers_by_id.values.find { | elt |
            elt.user_name == name
          }
        end

        alias_method :user_has_session?, :find_user_session_handler

        def ensure_session_for_user(name)
          if user_has_session?(name)
            # Note flagrant disregard of efficiency!
            find_user_session_handler(name).session
          else
            $trace.announce "Creating session for #{name}"
            session = RichlyCallingWrapper.new(@user_manager.session_for(name))

            @session_handlers_by_id[session.object_id] =
              SessionRequestHandler.new(session, name)
            session
          end
        end

        def ensure_no_session_for(user)
          if session_handler = find_user_session_handler(user)
            if session_id = session_handler.session.object_id
              deactivate_session(session_id)
            end
          end
        end


        def deactivate_session(session_id)
          handler = @session_handlers_by_id[session_id]
          @user_manager.deactivate_user_session(handler.user_name)
          @session_handlers_by_id.delete(session_id)
        end


        def request_handler_for(http_request)
          session_id = http_request.args['session']
          unless session_id
            $trace.warning("Unknown request #{http_request.inspect}")
            throw :problem,
              BadRequestPageSketch.unknown_request(http_request.name,
                                                   http_request.inspect)
          end
          
          session_request_handler = @session_handlers_by_id[session_id.to_i]
          unless session_request_handler
            $trace.warning("Unknown session for #{http_request.inspect}")
            throw :problem, BadRequestPageSketch.unknown_session
          end

          session_request_handler
        end


        todo 'handle uses both rescue and catch'
        # Would be better to just throw ProgramError, but I don't know
        # the right way to make Exceptions take object arguments. See
        # TimeclockError, which does it wrongly.
        
        def handle(http_request)
          $trace.event "Performing request #{http_request.inspect}"
          problem_description = catch(:problem) {
            begin
              case http_request.name
              when ''
                LoginPageSketch.new
              when 'login'
                user = http_request.args['name']
                sketch(ensure_session_for_user(user), user)
              when 'shut-down-server'
                exit
              when 'cause-null-pointer-exception'
                # Used to simulate a plausible program error.
                nil.some_method_nil_does_not_have
              else
                request_handler_for(http_request).handle(http_request)
              end
            rescue SystemExit # thrown by 'exit'
              exit
            rescue Exception => exception
              throw :problem, BadRequestPageSketch.exception(exception)
            end
          }
        end


        def sketch(session, user)
          jobs = session.jobs.values.collect { | job | job.full_name }
          if jobs.empty?
            FirstJobCreationPageSketch.new(session.object_id)
          else
            MainPageSketch.new(user, session)
          end
        end
      end
    end
  end
end
