# Feature tests for CSS selectors.
#
# Only shallow testing is needed since the selectors are immediately 
# converted to xpath and the other xpath tests will provide coverage 
# for the returned objects. This test more or less only verifies that the 
# respective classes have implemented the css selector as a query option.
#

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

# Since the CSS selectors were added to Watir::IE, these CSS selector tests
# will fail when using Firefox, until someone implements the method 
# "element_by_css(selector)" for that browser that is..  so for now only run 
# them for IE.
if Watir::Browser.default == 'ie'

	class TC_CSS_Selector < Test::Unit::TestCase
	  include Watir::Exception
	        
	  # Same test as TC_Divs_XPath::test_divs but using css selectors instead
	  def test_matching_queries
	    goto_page "div.html"
	    
	    assert_raises(UnknownObjectException) {browser.div(:css , "div[id='div77']").click }
	    assert_raises(UnknownObjectException) {browser.div(:css , "div[title='div77']").click }
	    
	    assert(browser.text_field(:css, "input[name='text1']").verify_contains("0") )  
	    browser.div(:css , "div[id='div3']").click
	    assert(browser.text_field(:css, "input[ name = 'text1' ]").verify_contains("1") )  
	    browser.div(:css , "div[id = div4]").click
	    assert(browser.text_field(:css, "input[name=text1]").verify_contains("0") )  
	  end
	  
	  def test_form
	    goto_page "forms2.html"
	    assert_equal(browser.form(:css, "#f2").action, "pass2.html")
	    assert_equal(browser.button(:css, "form #b2").value, "Click Me")
	  end
	
	  def test_image
	    goto_page "div.html"
	    assert_equal( "circle", browser.image(:css, "*[id ^= 'circ']").id )
	  end
	  
	  def test_link
	    goto_page "links1.html"
	    assert_equal( "link_name", browser.link(:css, "*[name *= ink_nam]").name )
	  end
	  
	  def test_table
	  	goto_page "table1.html"
	  	assert_equal( "Header", browser.cell(:css , ".sample th").text )
	  end
	end
	
end