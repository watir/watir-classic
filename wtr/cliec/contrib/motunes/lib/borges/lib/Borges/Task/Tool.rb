class Borges::Tool < Borges::Task

  def self.linkText
    return self.name
  end

  def root(aController)
    @root = aController
  end

  def self.title
    return self.name
  end

end

