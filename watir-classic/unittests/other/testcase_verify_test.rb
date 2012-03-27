# 3 tests, 10 assertions, 4 failures, 0 errors

require 'watir/testcase'

class VerifyTests < Watir::TestCase
  
  def test_verify
    verify true
    assert true
    verify false
    assert true
  end
  
  def test_verify_equal
    verify_equal 1, 1
    verify_equal 1, 2
    verify_equal 3, 4
  end
  
  def test_verify_match
    verify_match /\d*/, '123'
    verify_match 'foo', 'foobar'
    verify_match '...', 'A'
  end
end