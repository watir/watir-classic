# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'

module Trace

  # Convert a Message into a string. Format strings are odd. They have
  # this form:
  # '"<string-that-should-contain-#{}-type-directives"'
  # Note the double quotation.
  # The enclosed string is evaluated in the context of the message.
  #
  # The time format has the form used by Time#strftime.

  class Formatter
    include TraceErrors

    TWO_LINE_WITH_DATE =
      '"#{location} at #{time}#{$/}= #{topic} #{level}: #{body}"'
    TWO_LINE =
      '"#{location}#{$/}= #{topic} #{level}: #{body}"'

    VERBOSE_SORTABLE_TIME = "%Y/%m/%d %H:%M:%S"

    def initialize(format = TWO_LINE, time_format = nil)
      @format = format
      @time_format = time_format

      assert(!format.index(/\#{[^}]*time[^}]*}/) || time_format) {
        'If you use #{time} in a format, you must also give a time format.'
      }
    end
                   
    def accept(message)
      body = message.body
      # Note: strfmtime complains if you give it an empty format string,
      # so making the default time format be "" is no good.
      time = message.time.strftime(@time_format) if @time_format
      location = message.location
      level = message.level
      topic = message.topic

      eval(@format, binding)
    end
  end
end

