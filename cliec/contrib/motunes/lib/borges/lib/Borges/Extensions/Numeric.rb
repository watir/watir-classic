class Numeric

  def print_html_on(str)
    str << self.to_s
  end

  def to_cents
    return "$%0.2f" % self
  end

end

