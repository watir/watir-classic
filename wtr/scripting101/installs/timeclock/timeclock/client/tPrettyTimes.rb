require 'timeclock/client/PrettyTimes'

module Timeclock
  module Client

    class PrettyTimesTests < Test::Unit::TestCase

      def test_conversion_of_seconds_to_hours
        assert_equal(" 0.00 hours", PrettyTimes.columnar.hours(0))
        assert_equal("0.00 hours", PrettyTimes.tight.hours(0))

        # rounds up and down correctly.
        assert_equal(" 0.00 hours", PrettyTimes.columnar.hours(17))
        assert_equal("0.00 hours", PrettyTimes.tight.hours(17))

        # Ruby actually rounds the following up, which I think is incorrect,
        # but it's no big deal.
        assert_equal(" 0.01 hours", PrettyTimes.columnar.hours(18))
        assert_equal("0.01 hours", PrettyTimes.tight.hours(18))
        assert_equal(" 0.01 hours", PrettyTimes.columnar.hours(19))
        assert_equal("0.01 hours", PrettyTimes.tight.hours(19))
        assert_equal(" 0.01 hours", PrettyTimes.columnar.hours(17+36))
        assert_equal("0.01 hours", PrettyTimes.tight.hours(17+36))
        assert_equal(" 0.02 hours", PrettyTimes.columnar.hours(18+36))
        assert_equal("0.02 hours", PrettyTimes.tight.hours(18+36))

        # Works with floats
        assert_equal(" 1.03 hours", PrettyTimes.columnar.hours(60*60 + 36*2.9))
        assert_equal("1.03 hours", PrettyTimes.tight.hours(60*60 + 36*2.9))

        # Sometimes I can work more than ten hours.
        assert_equal("10.99 hours", PrettyTimes.columnar.hours(60*60*10.991))
        assert_equal("10.99 hours", PrettyTimes.tight.hours(60*60*10.991))

        # There's one special case where we want a singular.
        assert_equal(" 1.00 hour ", PrettyTimes.columnar.hours(60*60*1.00001))
        assert_equal("1.00 hour", PrettyTimes.tight.hours(60*60*1.00001))
      end

      def test_date_time_single_digits
        time = Time.local(2001, 1, 3, 1)
        # Columnar
        assert_equal("02001/01/03  1:00 AM",
                     PrettyTimes.columnar.date_time(time))
        assert_equal(" 1:00 AM", PrettyTimes.columnar.hhmm(time))
        assert_equal("02001/01/03", PrettyTimes.columnar.date(time))

        # Tight
        assert_equal("02001/01/03 1:00 AM",
                     PrettyTimes.tight.date_time(time))
        assert_equal("1:00 AM", PrettyTimes.tight.hhmm(time))
        assert_equal("02001/01/03", PrettyTimes.tight.date(time))
      end

      def test_with_two_digit_numbers
        time = Time.local(2001, 11, 12, 10, 0)
        # Columnar
        assert_equal("02001/11/12 10:00 AM",
                     PrettyTimes.columnar.date_time(time))
        assert_equal("10:00 AM", PrettyTimes.columnar.hhmm(time))
        assert_equal("02001/11/12", PrettyTimes.columnar.date(time))

        # Tight
        assert_equal("02001/11/12 10:00 AM",
                     PrettyTimes.tight.date_time(time))
        assert_equal("10:00 AM", PrettyTimes.tight.hhmm(time))
        assert_equal("02001/11/12", PrettyTimes.tight.date(time))
      end

      def test_abbreviated_date_times
        time = Time.local(2001, 9, 3, 1, 03)
        p = PrettyTimes.columnar(Time.local(2001, 9, 3, 13))

        # Columnar
        assert_equal(" 1:03 AM", p.date_time(time))
        # Ditto for a time before the given time.
        p = PrettyTimes.columnar(Time.local(2001, 9, 3))
        assert_equal(" 1:03 AM", p.date_time(time))


        p = PrettyTimes.columnar(Time.local(2001, 9, 4))
        assert_equal(" 1:03 AM yesterday", p.date_time(time))

        all_other_expected = "02001/09/03  1:03 AM"
        p = PrettyTimes.columnar(Time.local(2001, 9, 5))
        assert_equal(all_other_expected, p.date_time(time))

        p = PrettyTimes.columnar(Time.local(2001, 9, 2, 23, 59, 59))
        assert_equal(all_other_expected, p.date_time(time))

        p = PrettyTimes.columnar(Time.now)
        assert_equal(all_other_expected, p.date_time(time))

        # Different year and month
        p = PrettyTimes.columnar(Time.local(2002, 9, 3, 11, 03))
        assert_equal(all_other_expected, p.date_time(time))
        p = PrettyTimes.columnar(Time.local(2001, 10, 3, 11, 03))
        assert_equal(all_other_expected, p.date_time(time))


        # Tight
        p = PrettyTimes.tight(Time.local(2001, 9, 3, 13))
        assert_equal("1:03 AM", p.date_time(time))
        # Ditto for a time before the given time.
        p = PrettyTimes.tight(Time.local(2001, 9, 3))
        assert_equal("1:03 AM", p.date_time(time))


        p = PrettyTimes.tight(Time.local(2001, 9, 4))
        assert_equal("1:03 AM yesterday", p.date_time(time))

        all_other_expected = "02001/09/03 1:03 AM"
        p = PrettyTimes.tight(Time.local(2001, 9, 5))
        assert_equal(all_other_expected, p.date_time(time))

        p = PrettyTimes.tight(Time.local(2001, 9, 2, 23, 59, 59))
        assert_equal(all_other_expected, p.date_time(time))

        p = PrettyTimes.tight(Time.now)
        assert_equal(all_other_expected, p.date_time(time))

        # Different year and month
        p = PrettyTimes.tight(Time.local(2002, 9, 3, 11, 03))
        assert_equal(all_other_expected, p.date_time(time))
        p = PrettyTimes.tight(Time.local(2001, 10, 3, 11, 03))
        assert_equal(all_other_expected, p.date_time(time))
      end

      def test_insignificant_hours
        assert_equal(true, PrettyTimes.insignificant_hours(0.seconds))
        assert_equal(true, PrettyTimes.insignificant_hours(30.seconds))
        assert_equal(false, PrettyTimes.insignificant_hours(31.seconds))
      end
    end
  end
end
