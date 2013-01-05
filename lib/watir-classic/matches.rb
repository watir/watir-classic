# @private
class String
  def matches(x)
    self == x
  end
end

# @private
class Regexp
  def matches(x)
    self.match(x)
  end
end

# @private
class Integer
  def matches(x)
    self == x
  end
end

# @private
class Object
  def matches(x)
    raise TypeError, "#{self.class} is not supported as a locator"
  end
end
