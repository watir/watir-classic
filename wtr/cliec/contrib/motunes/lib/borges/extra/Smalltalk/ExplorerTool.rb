class ExplorerTool < Tool

  def go
    self.call(Explorer.on(root))
  end

  def self.linkText
    return 'Explore'
  end

  def self.title
    return 'Component Explorer'
  end

end

