class Borges::PluggableTask < Borges::Task

  def initialize(&block)
    @block = block
  end

  def go
    return @block.call(self)
  end

end

