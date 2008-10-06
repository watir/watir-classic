# tests of deferring when a Watir object is bound to a com object (lazy evaluation)
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
#require 'unittests/buttons_test.rb'

class TC_Defer < Test::Unit::TestCase
  def teardown
    @ie_new.close if defined?(@ie_new)
    browser.goto('about:blank')
  end
  tag_method :test_binding_to_newly_loaded_page, :fails_on_firefox, :attach
  def test_binding_to_newly_loaded_page
    @ie_new = Watir::IE.new
    text_field = @ie_new.text_field(:name, 'text1')
    button = @ie_new.button(:value, 'Clear Events Box')
    div = @ie_new.div(:name, 'divvy')
    @ie_new.goto($htmlRoot + "textfields1.html")
    assert_equal('Hello World', text_field.value)
    assert_equal('Clear Events Box', button.value)
    assert_equal('Div Text', div.text)
  end
  def test_binding_to_refreshed_page
    goto_page "textfields1.html"
    text_field = browser.text_field(:name, 'text1')
    button = browser.button(:value, 'Clear Events Box')
    div = browser.div(:name, 'divvy')
    browser.refresh
    assert_equal('Hello World', text_field.value)
    assert(text_field.enabled?)
    assert_equal('Clear Events Box', button.value)
    assert_equal('Div Text', div.text)
  end
  tag_method :test_exists, :fails_on_firefox, :attach
  def test_exists
    @ie_new = Watir::IE.new
    text_field = @ie_new.text_field(:name, 'text1')
    button = @ie_new.button(:value, 'Clear Events Box')
    div = @ie_new.div(:name, 'divvy')
    assert(!text_field.exists?)
    assert(!button.exists?)
    @ie_new.goto($htmlRoot + "textfields1.html")
    assert(text_field.exists?)
    assert(button.exists?)
    assert(div.exists?)
  end
end