module Timeclock

  module InterestingTimes
    def self.beginning_of_month(time_in_that_month)
      Time.local(time_in_that_month.year, time_in_that_month.month)
    end

    def self.next_month(time)
      if time.month == 12
        Time.local(time.year+1, 1)
      else
        Time.local(time.year, time.month+1)
      end
    end

    def self.yesterday(time)
      Time.local(time.year, time.month, time.day) - 24.hours
    end

    def self.same_day?(first, second)
      first.year == second.year &&
        first.month==second.month &&
        first.day == second.day
    end

    def self.day_after?(day, maybe_next_day)
      start_day = Time.local(day.year, day.month, day.day)
      beginning_next = start_day + 1.day
      end_next = beginning_next + 1.day - 1
      
      maybe_next_day.between?(beginning_next, end_next)
    end
  end

end
