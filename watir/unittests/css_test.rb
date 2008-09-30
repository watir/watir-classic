# feature tests for css
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CSS < Test::Unit::TestCase
  
  def divTester(message)
    divs = browser.getIE.document.getElementsByTagName("DIV")
    puts "Found #{divs.length} div tags"
    divs.each do |d|
      puts "Checking div #{d.id}"
      puts "div #{d.invoke("id") } class is #{d.invoke("className")  	}"
    end
  end
  
  def isMessageDisplayed(message)
    s = false
    divs = browser.getIE.document.getElementsByTagName("DIV")
    #puts "Found #{divs.length} div tags"
    divs.each do |d|
      #puts "----Checking div #{d.id} innertext is ( #{d.innerText}  )"
      
      if d.innerText.to_s.downcase.match( /#{message}/i )
        
        #puts "div #{d.invoke("id") } class is #{d.invoke("className")  	}"
        if d.invoke("className").to_s.downcase.match(/show/i)
          #puts "message is shown!!!"
          s = true
        end
        
      end
    end
    
    #puts "Not Shown " if s== false
    return s
  end
  
  tag_method :test_SuccessMessage, :fails_on_firefox
  def test_SuccessMessage
    goto_page "cssTest.html"
    browser.button( :caption , "Success").click
    
    #isMessageDisplayed( "Success" )
    #divTester( "Success" )
    assert( isMessageDisplayed("Success") )
    
    browser.button( :caption , "Failure").click
    
    assert(!isMessageDisplayed("Success") )
  end
end

