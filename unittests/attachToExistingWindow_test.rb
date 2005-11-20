# feature tests for attaching to existing IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ExistingWindow< Test::Unit::TestCase
    include Watir

    def goto_page(page)
      $ie.goto($htmlRoot + page)
    end

    def test_ExistingWindow
       goto_page 'buttons1.html'
       ie3 = nil

       assert_raises(NoMatchingWindowFoundException) { ie3 = IE.attach(:title, "missing") }
       assert_raises(NoMatchingWindowFoundException) { ie3 = IE.attach(:title, /missing/) }
       assert_raises(NoMatchingWindowFoundException) { ie3 = IE.attach(:url, "missing") }
       assert_raises(NoMatchingWindowFoundException) { ie3 = IE.attach(:url, /missing/) }

       ie3 = IE.attach(:title , /buttons/i)
       assert_equal("Test page for buttons", ie3.title)
       ie3 = nil

       ie3 = IE.attach(:title , "Test page for buttons")
       assert_equal("Test page for buttons", ie3.title)
       ie3 = nil

       ie3 = IE.attach(:url, /buttons1.html/)
       assert_equal("Test page for buttons", ie3.title)
       ie3 = nil

       #hard to test :url with explicit text
    end
end

class TC_NewWindow< Test::Unit::TestCase
    include Watir

    def setup
      $ie.goto($htmlRoot + "new_browser.html")
    end

    def test_simply_attach_to_new_window
        $ie.link(:text, 'New Window').click
        ie_new = IE.attach(:title, 'Pass Page')
        assert(ie_new.text.include?('PASS'))
        ie_new.close
    end
    
    def test_attach_to_slow_window_works_with_delay
        $ie.span(:text, 'New Window Slowly').click
        sleep 0.8
        ie_new = IE.attach(:title, 'Test page for buttons')
        assert(ie_new.text.include?('Blank page to fill in the frames'))
        ie_new.close
    end    

    def test_attach_to_slow_window_works_without_waiting
        $ie.span(:text, 'New Window Slowly').click
        IE.attach_timeout = 0.8
        ie_new = IE.attach(:title, 'Test page for buttons')
        assert(ie_new.text.include?('Blank page to fill in the frames'))
        ie_new.close
    end    

    def test_attach_timesout_when_window_takes_too_long
        $ie.text_field(:name, 'delay').set('2')
        $ie.span(:text, 'New Window Slowly').click
        assert_raise(Watir::Exception::NoMatchingWindowFoundException) do
            IE.attach(:title, 'Test page for buttons')
        end
        sleep 2 # clean up
        IE.attach(:title, 'Test page for buttons').close
    end        

end
