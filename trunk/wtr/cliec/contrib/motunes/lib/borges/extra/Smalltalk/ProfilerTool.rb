class ProfilerTool < Tool

  def go
    self.call(Profiler.new.child(root))
  end

  def self.linkText
    return 'Profile'
  end

  def self.title
    return 'Profiler'
  end

end

