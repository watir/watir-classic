$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED

require 'unittests/setup'
require 'watir/contrib/ie-new-process'
require 'watir/process'

class TC_New < Test::Unit::TestCase
  
  def setup
    @background_iexplore_processes = Watir::IE.process_count
    if @background_iexplore_process == 0
      @background = Watir::IE.new
      assert_equal 1, Watir::IE.process_count
      @background_iexplore_process = 1
    end
  end

  def teardown
    @background.close if @background
    @new.close if @new
    sleep 1.0 # give it time to close
  end

  def test_new_window_does_not_create_new_process
    @new = Watir::IE.new_window
    assert_equal @background_iexplore_processes, Watir::IE.process_count
  end
  
  def test_new_does_not_create_new_process
    @new = Watir::IE.new
    assert_equal @background_iexplore_processes, Watir::IE.process_count
  end
  
  def test_start_window_with_no_args_works_like_new_window
    @new = Watir::IE.start_window
    assert_equal @background_iexplore_processes, Watir::IE.process_count
  end
  
  def test_start_window_with_url_also_goes_to_that_page
    @new = Watir::IE.start_window 'http://wtr.rubyforge.org'
    assert_equal @background_iexplore_processes, Watir::IE.process_count
    assert_equal 'http://wtr.rubyforge.org/', @new.url
  end
  
  def test_new_process_creates_a_new_process
    @new = Watir::IE.new_process
    assert_equal @background_iexplore_processes + 1, Watir::IE.process_count
  end
  
  def test_start_process_with_arg_creates_a_new_process_and_goes_to_that_page
    @new = Watir::IE.start_process 'http://wtr.rubyforge.org'
    assert_equal @background_iexplore_processes + 1, Watir::IE.process_count
    assert_equal 'http://wtr.rubyforge.org/', @new.url
  end
end
     