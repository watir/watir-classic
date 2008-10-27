# feature tests for AutoIt wrapper
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/WindowHelper'
require 'watir/process'

$mydir = File.expand_path(File.dirname(__FILE__)).gsub('/', '\\')

class TC_JavaScript_Test < Test::Unit::TestCase
  @@javascript_page = $htmlRoot  + 'JavascriptClick.html'
  
  def ruby_process_count
    Watir::Process::count('rubyw.exe')
  end
  
  def teardown
    assert_equal @background_ruby_process_count, ruby_process_count
  end
  
  def setup
    @background_ruby_process_count = ruby_process_count
    begin
      WindowHelper.check_autoit_installed
    rescue
      raise "There is a Problem with Autoit - is it installed?"
    end
  end
  
  def check_dialog(extra_file, expected_result, &block)
    browser.goto(@@javascript_page)
    Thread.new { system("rubyw \"#{$mydir}\\#{extra_file}.rb\"") }
    
    block.call
    testResult = browser.text_field(:id, "testResult").value
    assert_match( expected_result, testResult )  
  end
  
  def test_alert_button
    check_dialog('jscriptExtraAlert', /Alert button!/) do
      browser.button(:id, 'btnAlert').click
    end
    
  end
  def test_alert_button2
    check_dialog('jscriptPushButton', /Alert button!/) do
      sleep 1
      WindowHelper.new.push_alert_button 
      sleep 1
    end
  end
  def test_confirm_button_ok
    check_dialog('jscriptExtraConfirmOk', /Confirm and OK button!/) do 
      browser.button(:id, 'btnConfirm').click
    end
  end
  def test_confirm_button_Cancel
    check_dialog('jscriptExtraConfirmCancel', /Confirm and Cancel button!/) do
      browser.button(:id, 'btnConfirm').click
    end
  end
  
end