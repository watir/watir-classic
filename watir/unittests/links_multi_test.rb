# feature tests for Links with multiple attributes
# revision: $Revision: 1009 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Links_Multi < Test::Unit::TestCase
  
  def setup
    goto_page 'links_multi.html'
  end
  
  tag_method :test_existing, :fails_on_firefox
  def test_existing
    assert_match(/not.html/, browser.link(:class_name, 'Papa').href)
    assert_match(/mama.html/, browser.link(:text, 'click').href)
  end
  
  def test_class_alias
    assert_match(/not.html/, browser.link(:class, 'Papa').href)
  end
  
  tag_method :test_hash_syntax, :fails_on_firefox
  def test_hash_syntax
    assert_match(/not.html/, browser.link(:class_name => 'Papa').href)
    assert_match(/mama.html/, browser.link(:text => 'click').href)
  end
  
  def test_class_and_text
    assert_match(/papa.html/, browser.link(:class => 'Papa', :text => 'click').href)
  end
  
  def test_class_and_index
    assert_match(/papa.html/, browser.link(:class => 'Papa', :index => 2).href)
  end  

  tag_method :test_not_found_single, :fails_on_firefox
  def test_not_found_single
    exception = assert_raise(UnknownObjectException) do
      browser.link(:id, 'Missing').href
    end
    assert_equal('Unable to locate element, using :id, "Missing"', exception.message)
  end
  
  tag_method :test_not_found_with_multi, :fails_on_firefox
  def test_not_found_with_multi
    exception = assert_raise(UnknownObjectException) do
      browser.link(:class => 'Missing', :index => 2).href
    end
    assert_equal('Unable to locate element, using {:class=>"Missing", :index=>2}', exception.message)
  end
  
end