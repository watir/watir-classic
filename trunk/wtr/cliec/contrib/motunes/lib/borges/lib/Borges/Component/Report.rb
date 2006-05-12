class Borges::Report < Borges::Component

  def initialize
    @rows = []
  end

  def rows(anArray)
    @rows = anArray
  end

end

