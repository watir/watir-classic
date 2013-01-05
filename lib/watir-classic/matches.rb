# @private
class String
  def matches(x)
    return self == x
  end
end

# @private
class Regexp
  def matches(x)
    return self.match(x)
  end
end

# @private
class Integer
  def matches(x)
    return self == x
  end
end

# @private
class Object
  def matches(x)
    raise TypeError, "#{self.class} is not supported as a locator"
  end
end
