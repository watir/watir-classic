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

class Object
  def matches(x)
    raise TypeError, "#{self.class} is not supported as a locator"
  end
end
