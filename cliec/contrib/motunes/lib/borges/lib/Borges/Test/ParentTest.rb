class ParentTest < Borges::Component

  attr_accessor :parent

  def initialize(parent)
    @parent = parent
  end

  def go
    @parent.inform('foo')
  end

  def render_content_on(r)
    r.anchor('swap parent') do go end
  end

end

