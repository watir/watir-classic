require 'watir/exceptions'

module Watir
  
  def wait_until(*args)
    Waiter.wait_until(*args) {yield}
  end  

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

  # Timeout for wait_until.
  attr_accessor :timeout
  
  @@default_polling_interval = 0.5
  @@default_timeout = 60.0

  def initialize(timeout=@@default_timeout,
                 polling_interval=@@default_polling_interval)
    @timeout = timeout
    @polling_interval = polling_interval
    @timer = TimeKeeper.new
  end

  # Execute the provided block until either (1) it returns true, or
  # (2) the timeout (in seconds) has been reached. If the timeout is reached,
  # a TimeOutException will be raised. The block will always
  # execute at least once.  
  # 
  # waiter = Waiter.new(5)
  # waiter.wait_until {puts 'hello'}
  # 
  # This code will print out "hello" for five seconds, and then raise a 
  # Watir::TimeOutException.
  def wait_until # block
    start_time = now
    until yield do
      if (duration = now - start_time) > @timeout
        raise Watir::Exception::TimeOutException.new(duration, @timeout),
          "Timed out after #{duration} seconds."
      end
      sleep @polling_interval
    end
  end  

  # Execute the provided block until either (1) it returns true, or
  # (2) the timeout (in seconds) has been reached. If the timeout is reached,
  # a TimeOutException will be raised. The block will always
  # execute at least once.  
  # 
  # Waiter.wait_until(5) {puts 'hello'}
  # 
  # This code will print out "hello" for five seconds, and then raise a 
  # Watir::TimeOutException.  

  # IDEA: wait_until: remove defaults from Waiter.wait_until
  def self.wait_until(timeout=@@default_timeout,
                      polling_interval=@@default_polling_interval)
    waiter = new(timeout, polling_interval)
    waiter.wait_until { yield }
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