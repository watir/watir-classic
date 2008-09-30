# feature tests for attaching to new Firefox windows
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_NewWindow < Test::Unit::TestCase
    tags :fails_on_ie

    def setup
      goto_page("new_browser.html")
    end

    def test_simply_attach_to_new_window_using_title
        browser.link(:text, 'New Window').click
        ff_new = browser.attach(:title, 'Pass Page')
        assert(ff_new.text.include?('PASS'))
        ff_new.close
        #browser.link(:text, 'New Window').click
    end
    
    def test_simply_attach_to_new_window_using_url
        browser.link(:text, 'New Window').click
        ff_new = browser.attach(:url, /pass\.html/)
        assert(ff_new.text.include?('PASS'))
        ff_new.close
        #browser.link(:text, 'New Window').click
    end

        def test_new_window_exists
        assert_raises(NoMatchingWindowFoundException , "NoMatchingWindowFoundException was supposed to be thrown" ) {   browser.attach(:title, "missing_title")   }  
        assert_raises(NoMatchingWindowFoundException , "NoMatchingWindowFoundException was supposed to be thrown" ) {   browser.attach(:url, "missing_url")   }  
    end
end
