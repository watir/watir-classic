# feature tests for wait_until

require 'watir/testcase'
require 'watir/waiter'
require 'spec' # gem install rspec

# used for unit testing
class MockTimeKeeper < Watir::TimeKeeper
  def sleep seconds
    @sleep_time += seconds
  end
  def now
    Time.now + @sleep_time
  end
end

class WaitUntilTest < Watir::TestCase
  
  def setup
    @waiter = Watir::Waiter.new
    @mock_checkee = Spec::Api::Mock.new "mock_checkee"

    # remove this to test with actual TimeKeeper intead of the Mock
    @waiter.timer = MockTimeKeeper.new
  end

  def teardown
    @mock_checkee.__verify
  end
  
  def test_no_time_passes_if_true
    @waiter.wait_until {true}
    @waiter.timer.sleep_time.should_equal 0.0
  end
  
  def test_three_tries_before_true
    @mock_checkee.should_receive(:check).exactly(3).times.and_return [false, false, true]
    @waiter.wait_until {@mock_checkee.check}
    @waiter.timer.sleep_time.should_equal 1.0
  end        
  
  def test_timeout
    @mock_checkee.should_receive(:check).any_number_of_times.and_return false
    lambda{@waiter.wait_until {@mock_checkee.check}}.should_raise Watir::Exception::TimeOutException
    @waiter.timer.sleep_time.should_be_close 10.25, 0.26
    @waiter.timer.sleep_time.should_satisfy {|x| [10.0, 10.5].include? x}
  end    
  
  def test_polling_interval
    @waiter.polling_interval = 0.1
    @mock_checkee.should_receive(:check).any_number_of_times.and_return false
    lambda{@waiter.wait_until {@mock_checkee.check}}.should_raise Watir::Exception::TimeOutException
    @waiter.timer.sleep_time.should_be_close 10.05, 0.07
  end

  def test_timeout_duration
    @mock_checkee.should_receive(:check).any_number_of_times.and_return false
    begin
      @waiter.wait_until {@mock_checkee.check} 
      flunk
    rescue Watir::Exception::TimeOutException => e
      e.duration.should_be_close 10.25, 0.26
      e.timeout.should_equal 10.0
    end
  end
  
  def test_timeout_override
    @waiter.polling_interval = 0.1
    @mock_checkee.should_receive(:check).any_number_of_times.and_return false
    lambda{@waiter.wait_until(2) {@mock_checkee.check}}.should_raise Watir::Exception::TimeOutException
    @waiter.timer.sleep_time.should_be_close 2.05, 0.06
  end
end    
    
