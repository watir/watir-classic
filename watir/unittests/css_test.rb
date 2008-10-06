# feature tests for css
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CSS < Test::Unit::TestCase
  
  def isMessageDisplayed(message)
    s = false
    divs = browser.getIE.document.getElementsByTagName("DIV")
    divs.each do |d|
      
      if d.innerText.to_s.downcase.match( /#{message}/i )
        if d.invoke("className").to_s.downcase.match(/show/i)
          s = true
        end
      end
    end
    
    return s
  end
  
  def setup
    goto_page "cssTest.html"
  end
  
  tag_method :test_SuccessMessage, :fails_on_firefox
  def test_SuccessMessage
    browser.button( :caption , "Success").click
    assert( isMessageDisplayed("Success") )
    
    browser.button(:caption, "Failure").click
    assert(!isMessageDisplayed("Success") )
  end
end

