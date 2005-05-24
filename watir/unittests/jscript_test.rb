# feature tests for AutoIt wrapper
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/WindowHelper'

$mydir = File.expand_path(File.dirname(__FILE__)).gsub('/', '\\')

class TC_JavaScript_Test < Test::Unit::TestCase
    include Watir
    @@attach = true
    @@javascript_page_title	= 'Alert Test'
    @@javascript_page		= $htmlRoot  + 'JavascriptClick.htm'
    
    def setup
        begin
            WindowHelper.check_autoit_installed
        rescue Watir::Exception::WatirException
            puts "Problem with Autoit - is it installed?."
            exit
        rescue
            puts "There is a Problem with Autoit - is it installed?."
            exit
        end
    end

    def goto_javascript_page()
        $ie.goto(@@javascript_page)
    end
    
    def check_dialog(extra_file, expected_result, &block)
        goto_javascript_page()
        Thread.new { system("rubyw #{$mydir}\\#{extra_file}.rb") }

        block.call
        testResult = $ie.text_field(:id, "testResult").value
        assert_match( expected_result, testResult )  
    end

    def test_alert_button()
        check_dialog('jscriptExtraAlert', /Alert OK/){ $ie.button(:id, 'btnAlert').click }
    end
    def test_alert_button2()
        check_dialog('jscriptPushButton', /Alert OK/){ sleep 0.1; WindowHelper.new.push_alert_button }
    end
    def test_confirm_button_ok()
        check_dialog('jscriptExtraConfirmOk', /Confirm OK/){ push_confirm_button }
    end
    def test_confirm_button_Cancel()
        check_dialog('jscriptExtraConfirmCancel', /Confirm Cancel/){push_confirm_button}
    end
        
    def push_confirm_button
        $ie.button(:id, 'btnInformation').click
    end
end