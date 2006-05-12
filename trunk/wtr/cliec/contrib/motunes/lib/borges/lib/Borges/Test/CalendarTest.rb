require 'observer'

class CalendarTest < Borges::Component

  def initialize
    @range = Borges::DateRangeSelector.new
    @range.add_observer(self)
    @calendar = Borges::DateTable.new(['a', 'b', 'c'])
    update_calendar
  end

  def render_content_on(r)
    r.render(@range)
    r.horizontal_rule
    r.render(@calendar)
  end

  def update(sym)
    puts "!! updating"
    update_calendar
  end

  def update_calendar
    @calendar.start_date = @range.start_date
    @calendar.end_date = @range.end_date
  end

  register_application('calendar')

end

