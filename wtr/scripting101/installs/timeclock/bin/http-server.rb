require "socket"
$:.unshift '..', '../fluid', '../ruby-trace'  
require 'timeclock/client/html/HttpGetParser'
require 'timeclock/client/html/LoginPageSketch'
require 'timeclock/util/misc'
require 'timeclock/util/Configuration'
require 'drb'

# On Windows, you'll need something like this:
# ENV["VW_TIMECLOCK_DATA_DIR"] = "C:/My Documents/Timeclock"
# The following line will fail if it's not set.
Timeclock::Configuration.ensure_data_dir
Timeclock::Configuration.start_log('http-server.txt')

require 'timeclock/client/html/RequestHandler'

module Timeclock

  module Client
    module Html

      def self.error(message, backtrace =  nil)
        puts message
        $trace.error message
        if backtrace
          puts backtrace
          $trace.error backtrace.join($/)
        end
      end

      def self.handle_requests_with(request_handler)
        http_parser = HttpGetParser.new
        listen = TCPServer.new(8080);

        user_manager = Timeclock::Server::NetworkableUserManager.new
        at_exit { user_manager.deactivate_all_sessions }
        request_handler = RequestHandler.new(user_manager)

        puts DRb.start_service('druby://:9000', request_handler).uri
        user_manager.advertise('', '9001')

        begin
          puts "Listening on #{listen.inspect}."
          loop do
            connection = listen.accept
            begin
              request = http_parser.parse(get_request_string(connection))
              sketch = request_handler.handle(request)
              connection.write("HTTP/1.1 200  OK\r\n" +
                               "Content-Type: text/html \r\n\r\n" +
                               sketch.to_xhtml)
            ensure
              connection.close
            end
          end
        ensure
          listen.shutdown
        end
      end

      def self.get_request_string(connection)
        request_string = connection.gets
        raise "Got nil request from socket" if request_string.nil?

        # Suck up irrelevant fields.
        loop do
          line = (connection.gets || "").chomp("\r\n")
          break if line.length == 0
        end
        request_string
      end

      def self.serve
        user_manager = Timeclock::Server::UserManager.new
        at_exit {
          user_manager.deactivate_all_sessions
        }
        request_handler = RequestHandler.new(user_manager)

        begin
          handle_requests_with(request_handler)
        rescue
          error("Network failure: " + $!.message, $!.backtrace)
          sleep 1
          retry
        end
      end

    end
  end
end

Timeclock::Client::Html::serve


