require 'timeclock/util/misc'
require 'timeclock/util/InterestingTimes'

module Timeclock
  module Client

    todo 'PrettyTimes and Time.now'
    # Note: the fact that this class uses Time.now means that this
    # command:
    #   at "a long time ago" do records end
    # will still produce record entries with "yesterday" relative to the
    # moment the command was typed, not the argument to 'at'. I think that's
    # probably right. But only probably.

    # Generic conversions of Times and integers representing seconds
    # into nicely formatted strings. 
    class PrettyTimes
      private_class_method :new

      def self.tight(relative_to = Time.now)
        new(true, relative_to)
      end

      def self.columnar(relative_to = Time.now)
        new(false, relative_to)
      end

      # Don't tell user about times less than this because it looks stupid
      # in the display.
      def self.insignificant_hours(seconds)
        seconds < 31
      end

      def initialize(tight, relative_to)
        @tight = tight
        @relative_to = relative_to
      end

      
      def hours(seconds)
        time_in_hours = seconds / 60.0 / 60.0
        hour_string = sprintf("%5.2f", time_in_hours)
        result = sprintf("%s %s",
                         hour_string,
                         hour_string == " 1.00" ? "hour " : "hours")
        result.strip! if @tight
        result
      end

      def hhmm(time)
        result = time.strftime("%I:%M %p")
        result[0,1]=' ' if result[0,1] == '0'
        result.strip! if @tight
        result
      end

      def date(time)
        time.strftime("0%Y/%m/%d")
      end

      def date_time(time)
        if InterestingTimes.same_day?(time, @relative_to)
          hhmm(time)
        elsif InterestingTimes.day_after?(time, @relative_to)
          sprintf("%s yesterday", hhmm(time))
        else
          sprintf("%s %s", date(time), hhmm(time))
        end
      end
    end
  end
end
