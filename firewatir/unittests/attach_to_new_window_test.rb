# feature tests for attaching to new Firefox windows
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_NewWindow < Test::Unit::TestCase
    include FireWatir

    def setup
      $ff.goto($htmlRoot + "new_browser.html")
    end

    def test_simply_attach_to_new_window_using_title
        $ff.link(:text, 'New Window').click
        ff_new = $ff.attach(:title, 'Pass Page')
        assert(ff_new.text.include?('PASS'))
        ff_new.close
        #$ff.link(:text, 'New Window').click
    end
    
    def test_simply_attach_to_new_window_using_url
        $ff.link(:text, 'New Window').click
        ff_new = $ff.attach(:url, /pass\.html/)
        assert(ff_new.text.include?('PASS'))
        ff_new.close
        #$ff.link(:text, 'New Window').click
    end

    def test_new_window_exists
        assert_raises(NoMatchingWindowFoundException , "NoMatchingWindowFoundException was supposed to be thrown" ) {   $ff.attach(:title, "missing_title")   }  
        assert_raises(NoMatchingWindowFoundException , "NoMatchingWindowFoundException was supposed to be thrown" ) {   $ff.attach(:url, "missing_url")   }  
    end
end
