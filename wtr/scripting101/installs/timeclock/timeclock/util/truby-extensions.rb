class RubyExtensionTests < Test::Unit::TestCase

  class Value
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  end
  
  def test_sum_by
    assert_equal(6, [Value.new(1), Value.new(2), Value.new(3)].sum_by(:value))
    assert_equal(0, [].sum_by(:value))
  end

  def test_sum
    assert_equal(0, [].sum)
    assert_equal(6, [1, 2, 3].sum)
  end

  def test_without_left_whitespace
    assert_equal("a
b", "a
      b".without_left_whitespace)

    # More varieties of whitespace - space at end.
    assert_equal("a
b
c  ", "    a
           b
        \t c  ".without_left_whitespace)

    # Does not eliminate lines
    assert_equal("
b", "
     b".without_left_whitespace)

    
  end

  def test_after_dots
    assert_equal("a
 b", ".a
      . b".after_dots)

    # Also strips whitespace
    assert_equal("a
b", "a
     b".after_dots)
  end

  def test_lines
    assert_equal("", lines)

    assert_equal("hi", lines('hi'))

    assert_equal("hi
                  bye".without_left_whitespace,
                 lines('hi', 'bye'))

    # lines ignores nils
    assert_equal("hi
                  bye".without_left_whitespace,
                 lines(nil, 'hi', nil, 'bye'))

    # lines expands arrays
    assert_equal("hi
                  byte
                  bye".without_left_whitespace,
                 lines([nil, 'hi', 'byte', nil, 'bye']))

    # and they can be mixed
    assert_equal("hi
                  byte
                  bye".without_left_whitespace,
                 lines([nil], 'hi', ['byte', nil, 'bye']))

    # Trailing newlines are removed.
    assert_equal("hi

                  byte
                  bye".without_left_whitespace,
                 lines("hi"+$/, 'byte', 'bye'+$/))

    # Note: multi-level arrays are undefined.
  end

  def test_prog1
    counter = 0
    assert_equal('hi', prog1('hi') { counter += 1 })
    assert_equal(1, counter)

    # Does NOT execute block if exception thrown. (This is implicit
    # in the language, but it's worth documenting, because that's
    # a typical use.

    thrower = proc { raise StandardError, "message." }

    begin
      prog1(thrower.call) { counter += 1 }
    rescue StandardError 
      assert_equal("message.", $!.message)
    else
      flunk
    end
    assert_equal(1, counter)
  end

end


