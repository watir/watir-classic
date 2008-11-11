class String
  def matches(x)
    return self == x
  end
end

class Regexp
  def matches(x)
    return self.match(x)
  end
end

class Integer
  def matches(x)
    return self == x
  end
end
