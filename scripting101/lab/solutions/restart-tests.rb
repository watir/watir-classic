# Demonstrate a bug in restarting the IE Controller.

require 'cl/iec'
require 'test/unit'

VISIBLE = TRUE

class RestartTests < Test::Unit::TestCase
  def set_up ()
    "Start on the login page."
    @iec = ClIEController.new(VISIBLE)
    @iec.navigate ("http://localhost:8080")
  end
    
  def tear_down ()
    "Shutdown browser."
    @iec.close
    #sleep(.1) # uncomment to avoid bug
  end

  def test_null()
  end

  def test_null2()
  end

  def test_null3()
  end

end

# Sometimes the following error will occur with the second test. For me it happens more often than not.

#Error occurred in test_null2(TimeClockLoginTests): WIN32OLERuntimeError: Unknown
# property or method : `busy'
#    HRESULT error code:0x800706be
#      The remote procedure call failed
#        c:/ruby/lib/ruby/site_ruby/1.6/cl/iec/cliecontroller.rb:165:in `method_m
#issing'
#        c:/ruby/lib/ruby/site_ruby/1.6/cl/iec/cliecontroller.rb:165:in `waitForI
#E'
#        c:/ruby/lib/ruby/site_ruby/1.6/cl/iec/cliecontroller.rb:136:in `navigate
#'
#        ie-timeclock-tests.rb:10:in `set_up'
#        ie-timeclock-tests.rb:49














