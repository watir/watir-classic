class << Time
  alias_method :original_now, :now

  def set(time)
    @now = time
  end

  def advance(seconds)
    @now += seconds
  end

  def now
    @now || original_now
  end

  def use_system_time
    @now = nil
  end
end
