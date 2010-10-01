# feature tests for css

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CSS < Test::Unit::TestCase
  
  def isMessageDisplayed(message)
    divs = browser.divs
    divs.each do |d|
      if d.text.downcase.match( /#{message}/i )
        if d.class_name.downcase.match(/show/i)
          return true
        end
      end
    end
    
    return false
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

  def test_inline_style
    assert_equal("300px", browser.form(:index, 1).style.width)
  end

  def test_internal_style
    assert_equal("#f00", browser.div(:id => "Container").style.backgroundColor)
  end
end

