require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/PageSketch'
require 'timeclock/client/PrettyTimes'

module Timeclock
  module Client
    module Html

      class BadRequestPageSketch < PageSketch

        def initialize(notification, details=nil)
          super "Probable Program Error"
          @notification = notification
          @details = details
        end

        def self.unknown_request(request_name, request_details)
          new("Timeclock got an unknown request '#{request_name}'.",
              request_details)
        end

        def self.unknown_session
          new('Your session no longer exists.')
        end

        def self.missing_arg(name)
          new("Missing argument '#{name}'.")
        end

        def self.exception(exception)
          new("An exception was raised: #{exception.class}('#{exception.message}')",
              '<pre>' + exception.backtrace.join($/) + '</pre>')
        end

        def details
          if @details
            p("Please include this detail: '#{@details}'")
          else
            ""
          end
        end
        
        def body_guts
          [p(@notification),
            p('Please report this problem to
              <a href="mailto:marick@testing.com">marick@testing.com</a>.'),
            details,
            p("Please also describe the page you came from and what you did to get to this page. Thank you.")]
        end
      end
    end
  end
end
