require 'timeclock/util/InterestingTimes'

module Timeclock

  class InterestingTimeTests < Test::Unit::TestCase

    def month_checker(time, expected_year, expected_month)
      assert_equal(expected_year, time.year)
      assert_equal(expected_month, time.month)
      assert_equal(1, time.day)
      assert_equal(0, time.hour)
      assert_equal(0, time.min)
      assert_equal(0, time.sec)
    end
    
    def test_beginning_of_month
      first = Time.local(2002, "jul") # start of month
      month_checker(InterestingTimes.beginning_of_month(first), 2002, 7)

      last = Time.local(2002, "aug") # end of month
      month_checker(InterestingTimes.beginning_of_month(last), 2002, 8)
    end

    def test_next_month
      december = Time.local(2002, "dec", 31, 23, 59, 59)
      month_checker(InterestingTimes.next_month(december), 2003, 1)

      january = Time.local(2002, "jan", 31)
      month_checker(InterestingTimes.next_month(january), 2002, 2)

      random = Time.local(2000, "mar", 12, 3, 5, 2)
      month_checker(InterestingTimes.next_month(random), 2000, 4)
    end

    def test_yesterday
      yesterday = InterestingTimes.yesterday(Time.local(2002, 1, 1))
      assert_equal(Time.local(2001, 12, 31), yesterday)

      yesterday = InterestingTimes.yesterday(Time.local(2003, 2, 5, 23, 59))
      assert_equal(Time.local(2003, 2, 4), yesterday)
    end

    def test_same_day
      beginning = Time.local(2002, 'dec', 2)
      end_day = Time.local(2002, 'dec', 2, 23, 59, 59)
      diff_year = Time.local(2001, 'dec', 2)
      diff_month = Time.local(2002, 'nov', 2)
      prev_day = Time.local(2002, 'dec', 1, 23, 59, 59)
      next_day = Time.local(2002, 'dec', 3)
      
      assert_equal(true, InterestingTimes.same_day?(beginning, beginning))
      assert_equal(true, InterestingTimes.same_day?(beginning, end_day))
      assert_equal(false, InterestingTimes.same_day?(beginning, diff_year))
      assert_equal(false, InterestingTimes.same_day?(beginning, diff_month))
      assert_equal(false, InterestingTimes.same_day?(beginning, prev_day))
      assert_equal(false, InterestingTimes.same_day?(beginning, next_day))
      
      assert_equal(true, InterestingTimes.same_day?(end_day, beginning))
      assert_equal(true, InterestingTimes.same_day?(end_day, end_day))
      assert_equal(false, InterestingTimes.same_day?(end_day, diff_year))
      assert_equal(false, InterestingTimes.same_day?(end_day, diff_month))
      assert_equal(false, InterestingTimes.same_day?(end_day, prev_day))
      assert_equal(false, InterestingTimes.same_day?(end_day, next_day))
    end

    def test_day_after
      beginning = Time.local(2002, 'nov', 2)
      end_day = Time.local(2002, 'nov', 2, 23, 59, 59)
      beginning_next_day = Time.local(2002, 'nov', 3)
      end_next_day = Time.local(2002, 'nov', 3, 23, 59, 59)
      beginning_two_days = Time.local(2002, 'nov', 4)
      next_day_next_year = Time.local(2003, 'nov', 2)
      next_day_next_month = Time.local(2002, 'dec', 2)
      day_before = Time.local(2002, 'nov', 1)
      
      assert_equal(false, InterestingTimes.day_after?(beginning, beginning))
      assert_equal(false, InterestingTimes.day_after?(beginning, end_day))
      assert_equal(true, InterestingTimes.day_after?(beginning, beginning_next_day))
      assert_equal(true, InterestingTimes.day_after?(beginning, end_next_day))
      assert_equal(false, InterestingTimes.day_after?(beginning, beginning_two_days))
      assert_equal(false, InterestingTimes.day_after?(beginning, next_day_next_year))
      assert_equal(false, InterestingTimes.day_after?(beginning, next_day_next_month))
      assert_equal(false, InterestingTimes.day_after?(beginning, day_before))

      
      assert_equal(false, InterestingTimes.day_after?(end_day, beginning))
      assert_equal(false, InterestingTimes.day_after?(end_day, end_day))
      assert_equal(true, InterestingTimes.day_after?(end_day, beginning_next_day))
      assert_equal(true, InterestingTimes.day_after?(end_day, end_next_day))
      assert_equal(false, InterestingTimes.day_after?(end_day, beginning_two_days))
      assert_equal(false, InterestingTimes.day_after?(end_day, next_day_next_year))
      assert_equal(false, InterestingTimes.day_after?(end_day, next_day_next_month))
      assert_equal(false, InterestingTimes.day_after?(end_day, day_before))
      
    end
  end
end

