# feature tests for css
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CSS < Test::Unit::TestCase
  
  def isMessageDisplayed(message)
    s = false
    divs = browser.divs
    divs.each do |d|
      if d.text.downcase.match( /#{message}/i )
        if d.class_name.downcase.match(/show/i)
          s = true
        end
      end
    end
    
    return s
  end
  
  def setup
    goto_page "cssTest.html"
  end
  
  def test_SuccessMessage
    browser.button( :caption , "Success").click
    assert( isMessageDisplayed("Success") )
    
    browser.button(:caption, "Failure").click
    assert_false(isMessageDisplayed("Success") )
  end
end

