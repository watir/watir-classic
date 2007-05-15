# rapidly open and close IE windows
require 'test/unit'
require 'watir'

class TC_OpenClose < Test::Unit::TestCase
  20.times do | i |
    define_method "test_#{i}" do
      sleep 0.05
      sleep i * 0.01
      ie = Watir::IE.start 'http://blogs.dovetailsoftware.com/blogs/gsherman/default.aspx'
      ie.close
    end
  end
end       