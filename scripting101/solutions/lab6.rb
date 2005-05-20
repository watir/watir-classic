# Suggested solution to Lab 6, Test Harness

require 'watir'
require 'test/unit'

$LOAD_PATH << '..' if $0 == __FILE__

class TestSuite < Test::Unit::TestCase
  def test_lab5_1
    load 'lab5_1.rb'
  end
  def test_lab5_2
    load 'lab5_2.rb'
  end
  def teardown
    ie = Watir::IE.attach(:title, /Timeclock/)
    ie.close
    ensure_no_user_data 'ruby' 
  end
end