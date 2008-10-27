# rapidly open and close IE windows
require 'test/unit'
require 'watir'
require 'watir/contrib/ie-new-process'

class ZZ_OpenClose < Test::Unit::TestCase
  def setup
    if browser
      browser.close 
      browser = nil 
    end
  end
  20.times do | i |
    define_method "test_#{i}" do
      sleep 0.05
      sleep i * 0.01
      ie = Watir::IE.new_process
      ie.goto 'http://blogs.dovetailsoftware.com/blogs/gsherman/default.aspx'
      ie.close
    end
  end
end       