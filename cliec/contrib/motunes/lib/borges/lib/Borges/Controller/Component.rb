class Borges::Component < Borges::Controller

  def footer
    return "" # XXX nil
  end

  def header
    return "" # XXX nil
  end

  def render_all_on(r)
    render_head_elements_on(r)
    render_header_on(r)
    render_content_on(r)
    render_footer_on(r)
  end

  def render_content_on(r)
  end

  def render_footer_on(r)
    r.render(footer)
  end

  def render_head_elements_on(r)
    r.style(style) unless style.nil?
    r.script(script) unless script.nil?
  end

  def render_header_on(r)
    r.render(header)
  end

  def render_with(context)
    render_all_on(default_renderer_class.new(context))
  end

  def default_renderer_class
    return Borges::HtmlRenderer
  end

  def script
    return nil
  end

  def style
    return nil
  end

end

