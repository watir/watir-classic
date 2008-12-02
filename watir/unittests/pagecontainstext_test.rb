# feature tests for IE::contains_text
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_contains_text < Test::Unit::TestCase
  
  def setup
    goto_page "textsearch.html"
  end        
  
  def test_text_found
    assert(browser.contains_text('slings and arrows of outrageous fortune'))
  end
  
  def test_text_not_found
    assert_false(browser.contains_text('So are they all, all honourable men'))
  end
  
  def test_regexp_found
    assert(browser.contains_text(/bodkin.*fardels/))
  end
  
  def test_regexp_not_found
    assert_false(browser.contains_text(/winding.*watch.*wit/))
  end
  
  def test_match_regexp_found
    $~ = browser.contains_text(/Messages ([0-9]+)/)
    assert_equal('42', $1)
  end
  
  def test_bad_search_argument
    assert_raises(ArgumentError) do
      browser.contains_text
    end
    assert_raises(ArgumentError) do
      browser.contains_text(nil)
    end
    assert_raises(ArgumentError) do
      browser.contains_text(42)
    end
  end
  
end

class TC_contains_text_in_new_ie < Test::Unit::TestCase
  tags :fails_on_firefox
  # Doesn't actually raise an error, but fails to close the window afterwards
  # http://jira.openqa.org/browse/WTR-265
  def setup
    @new_browser = Watir::Browser.new
  end
  def test_nothing_raised
    assert_nothing_raised {@new_browser.text.include? ''}
  end
  def teardown
    @new_browser.close
  end
end

class TC_contains_text_in_frame < Test::Unit::TestCase
  def setup
    goto_page "frame_links.html"
  end        
  def test_in_frame
    assert browser.frame('linkFrame').contains_text('The button is really a link')
  end
end