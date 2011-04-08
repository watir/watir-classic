$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_No_Wait_Commands < Test::Unit::TestCase
  def test_fire_event_no_wait
    goto_page "javascriptevents.html"
    browser.link(:text, "Check the Status").fire_event_no_wait("onMouseOver")
    assert_equal("It worked", browser.status) 
  end

  def test_set_no_wait_text_field
    goto_page "textfields1.html"
    browser.text_field(:name, "text1").set_no_wait("watir IE Controller")
    assert_equal("watir IE Controller", browser.text_field(:name, "text1").value)
  end

  def test_set_no_wait_text_select_list
    goto_page "selectboxes1.html"
    browser.select_list(:name,'sel1').set_no_wait(/Option 1/)
    assert_equal('Option 1', browser.select_list(:name , 'sel1').selected_options.first)
  end
end