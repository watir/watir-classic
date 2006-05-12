class Array

  def render_on(r)
    each do |item|
      item.render_on(r)
    end
  end

end

