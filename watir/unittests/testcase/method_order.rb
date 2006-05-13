# the default behavior of Test::Unit::TestCase should be to execute test 
# methods in alphabetical order.
# When executed, should print "A.B.C.D.E.F.G.H.I.J.K.L."

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__

require 'watir/testcase'

class TC1_Alphabetical_Default < Test::Unit::TestCase
  def test_b; print 'B'; end 
  def test_a; print 'A'; end
  def test_d; print 'D'; end
  def test_c; print 'C'; end
end

class TC2_Sequential < Test::Unit::TestCase
  execute :sequentially
  def test_b; print 'E'; end 
  def test_a; print 'F'; end
  def test_d; print 'G'; end
  def test_c; print 'H'; end
end

class TC3_Alphabetical_Specified < Test::Unit::TestCase
  execute :alphabetically
  def test_b; print 'J'; end 
  def test_a; print 'I'; end
  def test_d; print 'L'; end
  def test_c; print 'K'; end
end

