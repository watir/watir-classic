class ClosureTest < Borges::Component

  def ensure
    begin
      go
    ensure
      inform('ensure')
    end
  end

  def go
    [:a, :b, :c].each_with_index do |s, i|
      inform("#{s} #{i + 1}")
    end
  end

  def render_content_on(r)
    r.anchor('go') do go end
    r.space
    r.anchor('go with ensure') do self.ensure end
  end

end

