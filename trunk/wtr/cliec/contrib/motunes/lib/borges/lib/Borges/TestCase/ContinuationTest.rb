require 'test/unit'

class ContinuationTest < Test::Unit::TestCase

  def testBlockEscape
    tmp = 0
    tmp2 = nil
    x = proc do
      tmp += 1
      tmp2.call
    end

    callcc do |cc|
      tmp2 = cc
      x.call
    end

    tmp2 = proc do end

    x.call
    assert_equal(2, tmp)
  end

  ##
  # TODO finish porting

  def _testBlockTemps
    tmp = tmp2 = nil
    [1, 2, 3].each do |i|
      x = i
      if tmp.nil? then
        tmp2 = callcc do |cc|
          tmp = cc
          proc do :q end
        end
      end
      tmp2.call(x)
      x = 17
    end

    y = callcc do |cc|
      tmp.call(cc)
      42
    end

    assert_equal(1, y)
  end

  def testBlockVars
    continuation = nil
    tmp = 0
    tmp2 = nil
    tmp = callcc do |cc|
      continuation = cc
      0
    end + tmp

    unless tmp2.nil? then
      tmp2.call

    else
      [1, 2, 3].each do |i|
        callcc do |cc|
          tmp2 = cc
          continuation.call(i)
        end
      end

    end
    
    assert_equal(6, tmp)
  end

  ##
  # What should this print out?

  def testComprehension
=begin
    yin = proc do |x|
      Transcript.cr
      x
    end.call(Continuation.current)

    yang = proc do |x|
      Transcript.nextPut('*')
      x
    end.call(Continuation.current)

    yin.call(yang)
=end
  end

  ##
  # TODO finish porting

  def _testMethodTemps
    continuation = nil
    i = 0
    i = i + callcc do |cc|
      continuation = cc
      1
    end

    assert_equal(3, i) # assert(i ~= 3) # XXX '~='?

    unless i == 2 then
      continuation.call(2)
    end
  end

  def testSimpleCallCC
    continuation = nil
    x = callcc do |cc|
      continuation = cc
      false
    end

    unless x then
      continuation.call(true)
    end

    assert(x)
  end

  def testSimplestCallCC
    x = callcc do |cc|
      cc.call(true)
    end

    assert(x)
  end

end

