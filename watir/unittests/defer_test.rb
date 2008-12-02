# tests of deferring when a Watir object is bound to a com object (lazy evaluation)
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Defer < Test::Unit::TestCase
  def teardown
    @new_browser.close if defined?(@new_browser)
    browser.goto('about:blank')
  end
  tag_method :test_binding_to_newly_loaded_page, :fails_on_firefox, :attach
  def test_binding_to_newly_loaded_page
    @new_browser = Watir::Browser.new
    text_field = @new_browser.text_field(:name, 'text1')
    button = @new_browser.button(:value, 'Clear Events Box')
    div = @new_browser.div(:name, 'divvy')
    @new_browser.goto($htmlRoot + "textfields1.html")
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
    @new_browser = Watir::Browser.new
    text_field = @new_browser.text_field(:name, 'text1')
    button = @new_browser.button(:value, 'Clear Events Box')
    div = @new_browser.div(:name, 'divvy')
    assert_false(text_field.exists?)
    assert_false(button.exists?)
    @new_browser.goto($htmlRoot + "textfields1.html")
    assert(text_field.exists?)
    assert(button.exists?)
    assert(div.exists?)
  end
end