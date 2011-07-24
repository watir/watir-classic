$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_ElementCollections < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "multiple_specifiers.html"
  end

  def test_input_element_specifiers
    buttons = browser.buttons(:class, "two")
    assert 1, buttons.length
    assert "testbutton", buttons[0].name
    assert "two", buttons[0].class_name

    buttons = browser.buttons(:name, "testbutton")
    assert 2, buttons.length
    buttons.each do |btn|
      assert Watir::Button, btn.class
    end
    assert "testbutton", buttons[0].name    
    assert "one", buttons[0].class_name
    assert "testbutton", buttons[1].name
    assert "two", buttons[1].class_name
  end

  def test_brackets
    assert browser.buttons[0], browser.buttons(:class => "one")
    assert browser.buttons[1].exists?
    assert_raises(Watir::Exception::MissingWayOfFindingObjectException) {browser.buttons[2].exists?}
    assert_raises(Watir::Exception::MissingWayOfFindingObjectException) {browser.buttons[-1].exists?}
  end

  def test_first
    assert browser.buttons.first, browser.buttons(:class, "one")
  end

  def test_last
    assert browser.buttons.last, browser.buttons(:class => "two")
  end

  def test_frames_specifiers
    frames = browser.frames(:name => "testframe")
    assert 2, frames.length
    frames.each do |frame|
      assert Watir::Frame, frame.class
    end
  end

  def test_forms_specifiers
    forms = browser.forms(:name => "testform")
    assert 2, forms.size
    forms.each do |form|
      assert Watir::Form, form.class
    end
  end

  def test_elements_specifiers
    elements = browser.elements(:name => "testdivs")
    assert 2, elements.size
    elements.each do |element|
      assert Watir::Div, element.class
    end
  end

  def test_multiple_specifiers
    links = browser.links(:name => /test/, :class => /one|two/)
    assert 2, links.size

    links.each do |link|
      assert Watir::Link, link.class
    end
    assert "one", links[0].class_name
    assert "testlink", links[0].name
    assert "two", links[1].class_name
    assert "testlink", links[1].name
  end

  def test_unallowed_index_specifier
    assert_raises(Watir::Exception::MissingWayOfFindingObjectException) {browser.divs(:index, 1)}
  end

end

