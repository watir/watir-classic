# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'
require 'ruby-trace/misc'

module Trace

  class Message
    attr_accessor :body, :time, :location, :level, :topic

    def initialize(body, topic, level, additional_frames=0)
      # The optional additional_frames arg tells how many extra 
      # calls to look up the stack. This is used by utility methods that 
      # wrap the main trace methods.

      @body=body
      @topic=topic
      @level=level
      callstack=caller(3+additional_frames)
      @location=callstack ? callstack[0] : "<file?>:<line?>"
      @time=Time.now
    end

    def inspect
      Formatter.new(format=Formatter::TWO_LINE_WITH_DATE,
                    time_format=Formatter::VERBOSE_SORTABLE_TIME).accept(self)
    end

  end

  # This class reconstructs messages formatted in one of the standard
  # styles - Formatter::TWO_LINE_WITH_DATE or Formatter::TWO_LINE.
  # It's kind of dumb to put this class in this file.
  class MessageReader
    include TraceErrors
    include Util

    # What a timestamp looks like.
    Timeregex = %r{(\d\d\d\d)/(\d\d)/(\d\d) (\d\d):(\d\d):(\d\d)}

    def initialize
      # In Ruby 1.6.3, there seems to be a bug where reading in a
      # written local time is off by an hour. This corrects for that bug
      # or misunderstanding or whatever it is.
      written_time = Time.now
      s = written_time.strftime(Formatter::VERBOSE_SORTABLE_TIME)
      assert(Timeregex =~ s) { 'Failure to adjust local time.' }
      read_time = Time.local($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i,$6.to_i)

      @time_adjustment = read_time.to_i - written_time.to_i
      Internal.trace.announce("time adjustment = #{@time_adjustment}")
      # Using to_i because straight subtraction might yield fractional
      # seconds. I suspect that's rounding error or something, rather
      # than a true part of the adjustment. 
    end

    def from_file(filename)
      File.open(filename, "r") { |ios|
        from_stream(ios)
      }
    end
        

    def from_stream(ios)
      results = []

      line1_regex = /^(.*.rb:[\d]+)/
      line1_timestamp_regex = /.* at (.*)$/  # has a timestamp
      line2_regex = /= (.*) (.+): (.*)/
      
      format_err = proc { | bad_line | 
        lines("Message on line #{ios.lineno} is not properly formatted:",
              bad_line)
      }

      line1 = ios.gets
      while line1 != nil        # Ah, tail recursion...
        line1.chomp!
        assert(line1_regex =~ line1) { format_err.call(line1) }

        location = $1
        if line1_timestamp_regex =~ line1
          timestring = $1
          assert(timestring =~ Timeregex) { format_err.call(line1) }
          time = create_time($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i,$6.to_i)
        end

        line2 = ios.gets
        assert(line2 != nil) {"The final message is incomplete."}
        line2.chomp!
        assert(line2_regex =~ line2) { format_err.call(line2) }

        topic = $1
        level = $2
        body = $3
      
        # The body of the message may be several lines long.
        while (continuation = ios.gets) && !(continuation =~ line1_regex)
          body += $/ + continuation.chomp
        end
        line1 = continuation # ready for next iteration.
  
        message = Message.new(body, topic, level)
        message.location = location
        message.time = time
        results.push(message)
      end

      results
    end

    def create_time(year, month, day, hour, minute, second)
      Time.local(year, month, day, hour, minute, second) - @time_adjustment
    end
  end

end
