# feature tests for AutoIt wrapper
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/WindowHelper'

$mydir = File.expand_path(File.dirname(__FILE__)).gsub('/', '\\')

class TC_JavaScript_Test < Test::Unit::TestCase
  include Watir
  @@javascript_page = $htmlRoot  + 'JavascriptClick.html'
  
  def setup
    begin
      WindowHelper.check_autoit_installed
    rescue
      raise "There is a Problem with Autoit - is it installed?"
    end
  end
  
  def check_dialog(extra_file, expected_result, &block)
    $ie.goto(@@javascript_page)
    Thread.new { system("rubyw \"#{$mydir}\\#{extra_file}.rb\"") }
    
    block.call
    testResult = $ie.text_field(:id, "testResult").value
    assert_match( expected_result, testResult )  
  end
  
  def test_alert_button
    check_dialog('jscriptExtraAlert', /Alert button!/) do
      $ie.button(:id, 'btnAlert').click
    end
  end
  def test_alert_button2
    check_dialog('jscriptPushButton', /Alert button!/) do
      sleep 0.1 
      WindowHelper.new.push_alert_button 
    end
  end
  def test_confirm_button_ok
    check_dialog('jscriptExtraConfirmOk', /Confirm and OK button!/) do 
      $ie.button(:id, 'btnConfirm').click
    end
  end
  def test_confirm_button_Cancel
    check_dialog('jscriptExtraConfirmCancel', /Confirm and Cancel button!/) do
      $ie.button(:id, 'btnConfirm').click
    end
  end
  
end