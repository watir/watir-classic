
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_DocumentStandards_Quirks < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page 'quirks_document_standards.html'
  end

  def test_elements_exist_or_not
    assert(browser.document_mode.to_i == 5)
    assert(browser.text_field(:name,"quirks_text").exists?)
    browser.text_field(:name,"quirks_text").set "test"
    browser.text_field(:name,"quirks_text").fire_event "onClick"
    assert(browser.text_field(:name,"quirks_text").value == 'test')
  end
end

class TC_DocumentStandards_IE7 < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page 'ie7_document_standards.html'
  end

  def test_elements_exist_or_not
    assert(browser.document_mode.to_i == 7)
    assert(browser.text_field(:name,"ie7_text").exists?)
    browser.text_field(:name,"ie7_text").set "test"
    browser.text_field(:name,"ie7_text").fire_event "onClick"
    assert(browser.text_field(:name,"ie7_text").value == 'test')
  end
end

class TC_DocumentStandards_IE8 < Test::Unit::TestCase
  include Watir::Exception

  def setup
    goto_page 'ie8_document_standards.html'
  end

  def test_elements_exist_or_not
    assert(browser.document_mode.to_i == 8)
    assert(browser.text_field(:name,"ie8_text").exists?)
    browser.text_field(:name,"ie8_text").set "test"
    browser.text_field(:name,"ie8_text").fire_event "onClick"
    assert(browser.text_field(:name,"ie8_text").value == 'test')
  end
end

class TC_DocumentStandards_IE9 < Test::Unit::TestCase
  include Watir::Exception

  def setup
    goto_page 'ie9_document_standards.html'
  end

  def test_elements_exist_or_not
    assert(browser.document_mode.to_i == 9)
    assert(browser.text_field(:name,"ie9_text").exists?)
    browser.text_field(:name,"ie9_text").set "test"
    browser.text_field(:name,"ie9_text").fire_event "onClick"
    assert(browser.text_field(:name,"ie9_text").value == 'test')
  end
end