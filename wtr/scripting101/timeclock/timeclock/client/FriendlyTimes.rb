require 'timeclock/util/misc'
require 'timeclock/util/Steps'
require 'timeclock/util/Whine'
require 'parsedate'


module Timeclock
  module Client
    module FriendlyTimes

      include Steps
      include Whine

      def likely_time?(string)
        return true if string.strip == "now"
        if string =~ /yesterday/
          if string.sub(/yesterday/, "").strip == ""
            return false # Must provide a time with 'yesterday'
          else
            return true
          end
        end
        year, mon, day, hour, min = ParseDate.parsedate(string)
        !(hour.nil?) and !(min.nil?)   # want real true and false values.
      end

      
      def checking_time_from(time_string)  # tested through use
        step(:parse_time, time_string) {
          whine_unless(likely_time?(time_string),
                       :parse_time_format, time_string)

          time_from(time_string)
        }
      end

      def time_from(time_string)
        if time_string.strip == "now"
          Time.now
        elsif time_string =~ /yesterday/
          yesterday = Time.now - 24.hours
          ignored_year, ignored_month, ignored_day, hour, min =
            ParseDate.parsedate(time_string.sub(/yesterday/, ""))
          Time.local(yesterday.year, yesterday.month, yesterday.day, hour, min)
        else
          year, month, day, hour, min = ParseDate.parsedate(time_string)
          now = Time.now
          year = now.year if year.nil?
          month = now.month if month.nil?
          day = now.day if day.nil?
          Time.local(year, month, day, hour, min)
        end
      end
    end
  end
end
