# feature tests for AutoIt wrapper
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

$mydir = File.expand_path(File.dirname(__FILE__)).gsub('/', '\\')

class TC_JavaScript_Test < Test::Unit::TestCase
    include Watir
    @@attach = true
    @@javascript_page_title	= 'Alert Test'
    @@javascript_page		= $htmlRoot  + 'JavascriptClick.htm'
    
    def goto_javascript_page()
        if @@attach
            $ie = IE.attach(:title,@@javascript_page_title)
        else
            $ie.goto(@@javascript_page)
        end
    end
    
    def test_alert_button()
        @@attach=false
        goto_javascript_page()
        a = Thread.new {
            system("rubyw #{$mydir}\\jscriptExtraAlert.rb")
        }
        b = Thread.new { 
            push_button
        }
        a.join
        b.join
        testResult = $ie.text_field(:id, "testResult").to_s
        assert( testResult =~ /Alert OK/ )  
    end
    def test_confirm_button_ok()
        @@attach=false
        goto_javascript_page()
        a = Thread.new {
            system("rubyw #{$mydir}\\jscriptExtraConfirmOk.rb")
        }
        b = Thread.new { 
            push_confirm_button
        }
        a.join
        b.join
        testResult = $ie.text_field(:id, "testResult").to_s
        assert( testResult =~ /Confirm OK/ )  
    end
    def test_confirm_button_Cancel()
        @@attach=false
        goto_javascript_page()
        a = Thread.new {
            system("rubyw #{$mydir}\\jscriptExtraConfirmCancel.rb")
        }
        b = Thread.new { 
            push_confirm_button
        }
        a.join
        b.join
        testResult = $ie.text_field(:id, "testResult").to_s
        assert( testResult =~ /Confirm Cancel/ )  
    end
        
    def push_confirm_button
        $ie.button(:id,'btnInformation').click
    end
    def push_button()
        $ie.button(:id,'btnAlert').click
    end
end