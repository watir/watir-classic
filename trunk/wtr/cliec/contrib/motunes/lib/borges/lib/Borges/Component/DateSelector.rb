class Borges::DateSelector < Borges::Component

  def initialize(date)
    self.date = date
  end

  def date
    return Date.parse("#{@year}-#{@month}-#{@day}")
  end

  def date=(date)
    @day = date.mday
    @month = date.month
    @year = date.year
  end

  def date_is_valid?
    begin
      self.date

    rescue Exception
      return false

    end

    return true
  end

  def render_content_on(r)
    r.select(1..12, @month, proc do |i| @month = i end) do |ea|
      Date::MONTHNAMES[ea]
    end

    r.select(1..31, @day) do |i|
      @day = i
    end

    r.select(year_range, @year) do |i|
      @year = i
    end

    render_validation_error_on(r) unless date_is_valid?
  end

  def render_validation_error_on(r)
    r.span_class_with('error', 'invalid date')
  end

  def year_range
    return (Date.today.year - 1)...(Date.today.year + 2)
  end

end

