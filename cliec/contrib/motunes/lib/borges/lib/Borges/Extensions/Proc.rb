class Proc

  def handle_request(request)
    return call(request)
  end

  def render_on(r = nil)
    if r.nil? then
      return call
    else
      return call(r)
    end
  end

end

