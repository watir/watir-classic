# Not intended to be run as part of a larger suite.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__
require 'test/unit'
require 'watir'
require 'watir/process'
require 'watir/waiter'

class TC_IE_Each < Test::Unit::TestCase  
  def setup
    assert_equal 0, Watir::IE.process_count
    @hits = 0
    @ie = []
  end
  
  def hit_me
    @hits += 1
  end

  def test_zero_windows
    Watir::IE.each {hit_me}    
    assert_equal 0, @hits
  end
  
  def test_one_window
    @ie << Watir::IE.new_process
    Watir::IE.each {hit_me}    
    assert_equal 1, @hits
  end
  
  def test_two_windows
    @ie << Watir::IE.new_process
    @ie << Watir::IE.new_process
    Watir::IE.each {hit_me}    
    assert_equal 2, @hits
  end
  
  include Watir
  def teardown
    @ie.each {|ie| ie.close }
    wait_until {Watir::IE.process_count == 0}
  end
end