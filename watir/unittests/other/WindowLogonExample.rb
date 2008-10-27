$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/WindowHelper'

class TC_Logon_Test < Test::Unit::TestCase
  include Watir
  
  def goto_windows_login_page
    browser.goto('http://clio.lyris.com/')
  end
  
  
  def test_window_logon
    
    a = Thread.new {
      system('ruby WindowLogonExtra.rb')
      
    }
    b = Thread.new { 
      goto_windows_login_page
    }
    a.join
    b.join
  end
  
  
  
end