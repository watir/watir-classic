require 'timeclock/client/FriendlyTimes'
require 'timeclock/util/Time.rb'

module Timeclock
  module Client

    class FriendlyTimesTests < Test::Unit::TestCase

      include Timeclock::Client::FriendlyTimes

      def setup
        Time.use_system_time
      end

      def teardown
        Time.use_system_time
      end

      def test_time_parsing
        # Note: error checking is pretty minimal.

        now = Time.now
        t = "12:13"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(now.year, now.mon, now.day, 12, 13),
                     time_from(t))

        t = "12:13 pm"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(now.year, now.mon, now.day, 12, 13),
                     time_from(t))

        t = "12:13 am"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(now.year, now.mon, now.day, 0, 13),
                     time_from(t))

        t = "2001/01/23 1:23 am"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(2001, 1, 23, 1, 23),
                     time_from(t))

        t = "2001/1/3 2:03 am"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(2001, 1, 3, 2, 3),
                     time_from(t))

        t = "2001/01/23 1:23 AM"
        assert_equal(true, likely_time?(t))
        assert_equal(Time.local(2001, 1, 23, 1, 23),
                     time_from(t))

        now = Time.now
        Time.set(now)
        assert_equal(true, likely_time?("now"))
        assert_equal(now, time_from("now "))

        Time.set(Time.local(2001, "jan", 1, 12, 33))
        assert_equal(Time.local(2000, 12, 31, 23, 59),
                     time_from(" 23:59  yesterday "))

        assert_equal(Time.local(2000, 12, 31, 23, 12),
                     time_from(" 11:12 PM  yesterday "))

        Time.set(Time.local(2001, "nov", 1, 12, 33)) # variety
        assert_equal(Time.local(2001, 10, 31, 3),
                     time_from(" 3:00 am  yesterday "))


        # Error cases.
        assert_equal(false, likely_time?("5/13"))  # needs hour/minute
        assert_equal(false, likely_time?(" yesterday"))  # ditto
        assert_equal(false, likely_time?("2002/12"))
        assert_equal(false, likely_time?("jan 14"))
        assert_equal(false, likely_time?("12 pm"))  # needs minutes.
        assert_equal(false, likely_time?("misc"))  # a job name.
        assert_equal(false, likely_time?("a job name"))  # a job name.
        assert_equal(false, likely_time?("1"))  # reference to a display index
      end
      
    end
  end
end
