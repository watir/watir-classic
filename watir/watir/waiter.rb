require 'watir'

module Watir

class TimeKeeper
  attr_reader :sleep_time
  def initialize 
    @sleep_time = 0.0
  end
  def sleep seconds
    @sleep_time += Kernel.sleep seconds    
  end
  def now
    Time.now
  end
end

class Waiter
  # This is an interface to a TimeKeeper which proxies
  # calls to "sleep" and "Time.now".
  # Useful for unit testing Waiter.
  attr_accessor :timer

  # How long to wait between each iteration through the wait_until
  # loop. In seconds.
  attr_accessor :polling_interval

  # Default timeout for wait_until if not specified explicitly.
  attr_reader :default_timeout

  def initialize(polling_interval=0.5, default_timeout=10.0)
    @polling_interval = polling_interval
    @default_timeout = default_timeout
    @timer = TimeKeeper.new
  end

  # Executed the provided block until either (1) it returns true, or
  # (2) the timeout (in seconds) has been reached. If the timeout is reached,
  # a TimeOutException will be raised. The block will always
  # execute at least once.  
  # 
  # waiter = Waiter.new
  # waiter.wait_until(5) {puts 'hello'}
  # 
  # This code will print out "hello" for five seconds, and then raise a 
  # Watir::TimeOutException.
  def wait_until(timeout=nil) # block
    timeout ||= default_timeout
    start_time = now
    until yield do
      if (duration = now - start_time) > timeout
        raise Watir::Exception::TimeOutException.new(duration, timeout),
          "Timed out after #{duration} seconds."
      end
      sleep @polling_interval
    end
  end  
      
  private
  def sleep seconds
    @timer.sleep seconds
  end
  def now
    @timer.now
  end
end  
    
end # module