class String

  def pretty_print_html_on_indent(str, num)
    str << self
  end

  def print_html_on(str)
    str << self
  end

  def render_on_indent(r, level)
    r.encode_text(self)
  end

end

