require 'observer'

class Borges::DateRangeSelector < Borges::Component

  include Observable

  def initialize
    @start_date = Borges::DateSelector.new(Date.today)
    @end_date = Borges::DateSelector.new(Date.today + 10)
  end

  def start_date
    @start_date.date
  end

  def start_date=(date)
    puts "!! changing start_date from #{@start_date.date} to #{date}"
    @start_date.date = date
  end

  def end_date
    @end_date.date
  end

  def end_date=(date)
    puts "!! changing end_date from #{@end_date.date} to #{date}"
    @end_date.date = date
  end

  def add_days(days)
    if valid_date_range? then
      #puts "!! days: #{days}"
      #puts "!! start_date: #{start_date}, #{start_date.inspect}"
      #puts "!! end_date: #{end_date}, #{end_date.inspect}"
      start_date = @start_date.date + days
      end_date = @end_date.date + days
      #puts "!! start_date: #{start_date}, #{start_date.inspect}"
      #puts "!! end_date: #{end_date}, #{end_date.inspect}"
      change_dates
    end
  end

  def change_dates
    changed if valid_date_range?
  end

  def valid_date_range?
    #puts "!! start_date: #{start_date}, #{start_date.inspect}"
    #puts "!! end_date: #{end_date}, #{end_date.inspect}"
    #puts "!! start_date valid? #{@start_date.date_is_valid?}"
    #puts "!! end_date valid? #{@end_date.date_is_valid?}"
    #puts "!! start_date <= end_date? #{@start_date.date <= @end_date.date}"
    return ((@start_date.date_is_valid? &&
             @end_date.date_is_valid?) &&
            @start_date.date <= @end_date.date)
  end

  def date_range_size
    if valid_date_range? then
      return end_date - start_date
    else
      return 0
    end
  end

  def self.example
    return self.new
  end

  def next_dates
    add_days(date_range_size)
  end

  def previous_dates
    add_days(date_range_size * -1)
  end

  def render_content_on(r)
    r.form do
      r.table do
        r.table_row do
          r.table_data do r.text('From:') end
          r.table_data do r.render(@start_date) end
        end

        r.table_row do
          r.table_data do r.text('To:') end
          r.table_data do r.render(@end_date) end
        end

        r.table_row do
          r.table_data do r.space end

          r.table_data do
            r.submit_button('Previous') do
              previous_dates
            end

            r.submit_button('Next') do
              next_dates
            end

            r.space

            r.submit_button('Go') do
              change_dates
            end
          end
        end
      end

      r.paragraph('Invalid Date Range') unless valid_date_range?
    end
  end

  register_application('rates')

end

