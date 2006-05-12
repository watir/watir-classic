# Extensions to the Ruby standard library.

class Integer
  # conversions of times to units of seconds.
  def second
    self
  end
  alias_method :seconds, :second

  def minute
    60 * self
  end
  alias_method :minutes, :minute

  def hour
    60.minutes * self
  end
  alias_method :hours, :hour

  def day
    24.hours * self
  end
  alias_method :days, :day
end

class String
  def without_left_whitespace
    # I don't strip before the second gsub because that would
    # delete a first blank line.
    gsub(/^[ \t]*/, "").gsub(/\n[ \t]*/, "\n")
  end

  # Strip everything before and including the first dot on each line.
  # For example:
  # blah_blah(".a
  #            .   b").after_dots
  # is the same as this:
  #a
  #   b
  #
  def after_dots
    without_left_whitespace.gsub(/^\./, "")
  end
end

module Enumerable
  def inject(n)
    each { | elt | n = yield(n, elt) }
    n
  end

  def sum_by(message)
    inject(0) { | sum, value | sum + value.send(message) }
  end

  def sum
    sum_by :no_op
  end
end

class Object
  def no_op
    self
  end
end


module Kernel
  def lines(*args)
    args.flatten.compact.join($/).chomp
  end

  # This is used to execute a block iff the argument did not
  # throw an exception. The name is from Lisp. I should probably be
  # good and use some other name.
  def prog1(retval)
    yield
    retval
  end
end
