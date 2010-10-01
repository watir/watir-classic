$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_PopUps < Test::Unit::TestCase
  tags :must_be_visible, :creates_windows, :unreliable

  def setup
    browser.goto("file://#{$myDir}/html/popups1.html")
  end
  
  def startClicker( button , waitTime = 0.5)
    w = WinClicker.new
    longName = browser.dir.gsub("/" , "\\" )
    shortName = w.getShortFileName(longName)
    c = "start rubyw #{shortName }\\watir\\clickJSDialog.rb #{button } #{ waitTime} "
    puts "Starting #{c}"
    w.winsystem(c )   
    w = nil
  end
  
  def test_simple
    startClicker("OK")
    browser.button("Alert").click
  end
  
  def test_confirm
    startClicker("OK")
    browser.button("Confirm").click
    assert( browser.text_field(:name , "confirmtext").verify_contains("OK") )
    
    startClicker("Cancel")
    browser.button("Confirm").click
    assert( browser.text_field(:name , "confirmtext").verify_contains("Cancel") )
  end
  
  def xtest_Prompt
    startClicker("OK")
    browser.button("Prompt").click
  end
end

