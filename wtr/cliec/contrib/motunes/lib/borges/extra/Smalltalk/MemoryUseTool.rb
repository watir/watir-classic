class MemoryUseTool < Tool

  def go
    self.call(MemoryUse.new.root(self.session))
  end

  def self.linkText
    return 'Memory Use'
  end

  def self.title
    return 'Memory Use'
  end

end

