$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/process'
require 'watir/contrib/ie-new-process'

class TC_New < Test::Unit::TestCase
  include Watir::Process
  
  def ie_process_count
    count_processes('iexplore.exe')
  end
  
  def setup
    @background_iexplore_processes = ie_process_count
    if @background_iexplore_process == 0
      @background = Watir::IE.new
      assert_equal 1, ie_process_count
      @background_iexplore_process = 1
    end
  end
  
  def teardown
    @background.close if @background
    @new.close if @new
    sleep 0.5 # give it time to close
  end

  def test_new_window_does_not_create_new_process
    @new = Watir::IE.new_window
    assert_equal @background_iexplore_processes, ie_process_count
  end
  
  def test_start_window_with_no_args_works_like_new_window
    @new = Watir::IE.start_window
    assert_equal @background_iexplore_processes, ie_process_count
  end
  
  def test_start_window_with_url_also_goes_to_that_page
    @new = Watir::IE.start_window 'http://wtr.rubyforge.org'
    assert_equal @background_iexplore_processes, ie_process_count
    assert_equal 'http://wtr.rubyforge.org/', @new.url
  end
  
  def test_new_process_creates_a_new_process
    @new = Watir::IE.new_process
    assert_equal @background_iexplore_processes + 1, ie_process_count
  end
end
     