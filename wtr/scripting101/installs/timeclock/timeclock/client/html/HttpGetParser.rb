require 'timeclock/util/ruby-extensions'
require 'timeclock/util/program-error'
require 'cgi'

module Timeclock
  module Client
    module Html

      class HttpRequest
        attr_reader :name, :args, :original_get_string

        def initialize(name, args, original_get_string = "<a test command>")
          @name = name
          @args = args
          @original_get_string = original_get_string
        end

        def has_arg?(name)
          @args.has_key?(name)
        end

        def inspect
          "#{name}#{args.inspect} (from #{original_get_string})"
        end

      end
        
      class HttpGetParser

        def parse(get_string)
          substrings = get_string.split(' ')
          assert(substrings[0] == 'GET', 
                 "The server sent an odd HTTP command: " + get_string)
          if substrings[1] =~ %r{/(.*)\?(.*)}
            name = $1
            args_and_values = $2.split(/[=&]/, -1)
            unescaped = args_and_values.collect { | elt | CGI.unescape(elt) }
            args = Hash[*unescaped]
            
          else
            name = substrings[1][1..-1]
            args = {}
          end
          HttpRequest.new(name, args, get_string)
        end

      end
    end
  end
end
