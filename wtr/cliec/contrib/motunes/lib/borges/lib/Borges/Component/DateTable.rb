require 'date'

class Borges::DateTable < Borges::Component

  attr_reader :start_date, :end_date
  attr_accessor :rows

  def initialize(rows)
    @start_date = nil
    @end_date = nil
    @rows = rows
  end

  def dates_do_separated_by(daily_block, monthly_block)
    month = @dates_cache.first.month

    @dates_cache.each do |date|
      unless date.month == month then
        month = date.month
        monthly_block.call
      end

      daily_block.call(date)
    end

    monthly_block.call
  end

  def end_date=(date)
    @end_date = date
    update_cache
  end

  def months_and_lengths(&block)
    count = 0
    last = nil

    dates_do_separated_by(proc do |ea|
      count += 1
      last = ea

    end, proc do
      block.call(Date.parse("#{last.year}-#{last.month}-#{1}"), count)
      count = 0

    end)
  end

  def render_cell_for_date_row_index_on(aDate, anObject, aNumber, r)
    r.table_data do r.space end
  end

  def render_content_on(r)
    r.attributes[:border] = 1
    r.css_class('DateTable')
    r.table do
      r.table_row do render_month_headings_on(r) end
      r.table_row do render_day_headings_on(r) end
      @rows.each_with_index do |ea, i|
        r.table_row do
          render_row_index_on(ea, i, r)
        end
      end
    end
  end

  def render_day_headings_on(r)
    render_heading_spacer_on(r)

    dates_do_separated_by(proc do |date|
      r.css_class('DayHeading')
      r.table_heading(date.mday)
    end, proc do
      render_heading_spacer_on(r)
    end)
  end

  def render_heading_for_row_on(obj, r)
    r.css_class('RowHeading')
    r.table_heading(obj)
  end

  def render_heading_spacer_on(r)
    r.table_data do end
  end

  def render_month_headings_on(r)
    months_and_lengths do |month, length|
      render_heading_spacer_on(r)
      r.css_class('MonthHeading')
      r.attributes[:colspan] = length
      r.table_heading do
        r.text(Date::MONTHNAMES[month.month])
        r.space
        r.text(month.year)
      end
    end
  end

  def render_row_index_on(obj, num, r)
    render_heading_for_row_on(obj, r)
    dates_do_separated_by(proc do |date|
      render_cell_for_date_row_index_on(date, obj, num, r)
    end, proc do
      render_heading_spacer_on(r)
    end)
  end

  def start_date=(date)
    @start_date = date
    update_cache
  end

  def update_cache
    return self if @start_date.nil? || @end_date.nil? 
    
    @dates_cache = []
    date = @start_date
    until date > @end_date do
      @dates_cache << date
      date = date.next
    end
  end

end

