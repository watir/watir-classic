class ErrorTest < Borges::Component

  def render_content_on(r)
    r.anchor('Raise error') do 1/0 end
  end

end

