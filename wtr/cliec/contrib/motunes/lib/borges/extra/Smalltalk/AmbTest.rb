require 'test/unit'
require 'Amb'

class AmbTest < Test::Unit::TestCase

  def setup
    @amb = Amb.new
  end

  def pick_a_number
    return pick_a_number_greater_than(0)
  end

  def pick_a_number_greater_than(num)
    return @amb.value_of([proc do
      num + 1
    end, proc do
      pick_a_number_greater_than(num + 1)
    end])
  end

  def test_all_values_above_five
    results = @amb.all_values do
      x = @amb.one_of(1..10)
      @amb.assert(x > 5)
      x
    end

    assert_equal([6, 7, 8, 9, 10], results)
  end

  def test_maybe
    x = @amb.maybe
    y = @amb.maybe
    z = (not @amb.maybe)
  
    @amb.deny(x == y)
    @amb.deny(x == z)
    
    assert_equal([true, false, false], [x, y, z])
  end

  def test_pick_a_number
    assert_equal(1, pick_a_number)
  end

  def test_pick_a_number_above_five
    x = pick_a_number
    @amb.assert(x > 5)
    assert_equal(6, x)
  end

  ##
  # Baker, Cooper, Fletcher, Miller, and Smith live on different
  # floors of an apartment house that contains only five floors;
  # Baker does not live on the top floor; Cooper does not live on
  # the bottom floor; Fletcher does not live on either the top or
  # the bottom floor; Miller lives on a higher floor than does
  # Cooper; Smith does not live on a floor adjacent to Fletcher's;
  # Fletcher does not live on a floor adjacent to Cooper's; Where
  # does everyone live?

  def test_sicp_logic_problem
  
  # This implementation is too slow - uncomment to actually run it
  
=begin
    baker = @amb.one_of(1..5)
    cooper = @amb.one_of(1..5)
    fletcher = @amb.one_of(1..5)
    miller = @amb.one_of(1..5)
    smith = @amb.one_of(1..5)

    @amb.assert([baker, cooper, fletcher, miller, smith].length == 5)

    @amb.deny(baker == 5)
    @amb.deny(cooper == 1)
    @amb.deny(fletcher == 5)
    @amb.deny(fletcher == 1)
    @amb.assert(miller > cooper)
    @amb.deny((smith - fletcher).abs == 1)
    @amb.deny((fletcher - cooper).abs == 1)

    assert_equal([3, 2, 4, 5, 1], [baker, cooper, fletcher, miller, smith])
=end
  end

  ##
  # Baker, Cooper, Fletcher, Miller, and Smith live on different
  # floors of an apartment house that contains only five floors;
  # Baker does not live on the top floor; Cooper does not live on
  # the bottom floor; Fletcher does not live on either the top or
  # the bottom floor; Miller lives on a higher floor than does
  # Cooper; Smith does not live on a floor adjacent to Fletcher's;
  # Fletcher does not live on a floor adjacent to Cooper's; Where
  # does everyone live?"

  def test_sicp_logic_problem_faster
    fletcher = @amb.one_of(1..5)
    @amb.deny(fletcher == 5)
    @amb.deny(fletcher == 1)
  
    smith = @amb.one_of(1..5)
    @amb.deny((smith - fletcher).abs == 1)
  
    cooper = @amb.one_of(1..5)
    @amb.deny(cooper == 1)
    @amb.deny((fletcher - cooper).abs == 1)
  
    miller = @amb.one_of(1..5)
    @amb.assert(miller > cooper)
  
    baker = @amb.one_of(1..5)
    @amb.deny(baker == 5)
    
    @amb.assert([baker, cooper, fletcher, miller, smith].length == 5)

    assert_equal([3, 2, 4, 5, 1], [baker, cooper, fletcher, miller, smith])
  end

  def test_solve_an_equation
    x = @amb.one_of(1..10)
    y = @amb.one_of(1..10)
    @amb.assert((y * x) == 42)
    assert_equal(6, x)
    assert_equal(7, y)
  end

end

