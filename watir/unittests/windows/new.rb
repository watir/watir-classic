$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/process'

class TC_New < Test::Unit::TestCase
  include Watir::Process
  
  def ie_process_count
    count_processes('iexplore.exe')
  end
  
  def setup
    @background_iexplore_processes = ie_process_count
  end
  
  def teardown
    @background.close if @background
    @new.close if @new
  end

  def test_new_window_does_not_create_new_process
    if @background_iexplore_process == 0
      @background = Watir::IE.new
      assert_equal 1, ie_process_count
    end
    @new = Watir::IE.new
    assert_equal [1, @background_iexplore_processes].max, ie_process_count
  end
end
    
    
     