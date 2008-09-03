# unit tests for IOString in iostring.rb

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/iostring'
require 'test/unit'

class IOStringTests < Test::Unit::TestCase
  include MockStdoutTestCase
  def setup
    @mockout = IOString.new ""
    $stdout = @mockout
  end
  def test_io_string_write
    puts "hello"
    assert_equal "hello\n", @mockout
  end
  def test_iostring_readline
    puts "hello"
    puts "there"
    $stdout = STDOUT
    assert_equal "hello", @mockout.readline!
    assert_equal "there", @mockout.readline!
  end
  def test_iostring_realine_no_final_cr
    print "hello"
    $stdout = STDOUT
    assert_equal "hello", @mockout.readline!
  end
  def test_ending_with_cr
    puts "hello"
    @mockout.readline!
    assert_equal nil, @mockout.readline!
  end
  def test_ending_without_cr
    print "hello"
    @mockout.readline!
    assert_equal nil, @mockout.readline!
  end
  def test_blank_line
    puts "hello"
    puts
    puts "there"
    @mockout.readline!
    assert_equal "", @mockout.readline!
  end
end


