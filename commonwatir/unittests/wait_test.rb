$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class Wait < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "wait.html"
    browser.refresh
  end

  def test_wait_until
    div = browser.div(:id => "div1")
    assert div.visible?
    browser.link(:id => "link1").click

    browser.wait_until(2) {not div.visible?}
    assert !div.visible?
  end

  def test_wait_until_exception
    assert_raises(Watir::Wait::TimeoutError) {browser.wait_until(0.1) {false}}
  end

  def test_wait_while
    div = browser.div(:id => "div1")
    assert div.visible?
    browser.link(:id => "link1").click

    browser.wait_while(2) {div.visible?}
    assert !div.visible?
  end

  def test_wait_while_exception
    assert_raises(Watir::Wait::TimeoutError) {browser.wait_while(0.1) {true}}
  end

  def test_present?
    div = browser.div(:id => "div1")
    assert div.exists?
    assert div.visible?
    assert div.present?

    browser.link(:id => "link1").click
    browser.wait_until(2) {!div.visible?}
    assert div.exists?
    assert !div.visible?
    assert !div.present?

    non_existing_div = browser.div(:id => "non-existing")
    assert !non_existing_div.exists?
    assert_raises(Watir::Exception::UnknownObjectException) {non_existing_div.visible?}
    assert !non_existing_div.present?
  end

  def test_when_present
    browser.link(:id => "link1").click
    div = browser.div(:id => "div1")
    assert_equal "div1", div.when_present(2).text
    assert div.visible?
  end

  def test_when_present_block
    browser.link(:id => "link1").click
    div = browser.div(:id => "div1")
    div.when_present(2) do |d|
      assert_equal "div1", d.text
    end
    assert div.visible?
  end

  def test_when_present_exceptions
    assert_raises(NoMethodError) {browser.div(:id => "div1").when_present(0.1).non_existing_method}
    assert_raises(Watir::Wait::TimeoutError) {browser.div(:id => "non-existing").when_present(0.1).text}
  end

  def test_when_present_element_id
    browser.link(:id => "link1").click
    div = browser.div(:id => "div1")
    assert_equal "div1", div.when_present(2).id
    assert div.visible?
  end

  def test_wait_until_present
    browser.link(:id => "link1").click

    div = browser.div(:id => "div1")
    browser.link(:id => "link1").click
    div.wait_until_present(2)
    assert div.visible?
  end

  def test_wait_until_present_exception
    assert_raises(Watir::Wait::TimeoutError) {browser.div(:id => "non-existing").wait_until_present(0.1)}
  end

  def test_wait_while_present
    div = browser.div(:id => "div1")
    browser.link(:id => "link1").click
    div.wait_while_present(2)
    assert !div.visible?
  end

  def test_wait_while_present_exception
    assert_raises(Watir::Wait::TimeoutError) {browser.div(:id => "div1").wait_while_present(0.1)}
  end

  def test_wait_module_until
    div = browser.div(:id => "div1")
    assert div.visible?
    browser.link(:id => "link1").click

    Watir::Wait.until(2) {not div.visible?}
    assert !div.visible?
  end

  def test_wait_module_while
    div = browser.div(:id => "div1")
    assert div.visible?
    browser.link(:id => "link1").click

    Watir::Wait.while(2) {div.visible?}
    assert !div.visible?
  end
end
