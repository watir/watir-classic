# tests of deferring when a Watir object is bound to a com object.

# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'unittests/textfields_test.rb'

class TC_Defer < Test::Unit::TestCase
    def teardown
        @ie_new.close if defined?(@ie_new)
    end
    def test_no_page_loaded
        @ie_new = Watir::IE.new
        text_field = @ie_new.text_field(:name, 'text1')
        @ie_new.goto($htmlRoot + "textfields1.html")
        assert_equal('Hello World', text_field.value)
    end
    def test_refresh
        $ie.goto($htmlRoot + "textfields1.html")
        text_field = $ie.text_field(:name, 'text1')
        $ie.refresh
        assert_equal('Hello World', text_field.value)
        assert(text_field.enabled?)
    end
    def test_exists
        @ie_new = Watir::IE.new
        text_field = @ie_new.text_field(:name, 'text1')
        assert_false(text_field.exists?)
        @ie_new.goto($htmlRoot + "textfields1.html")
        assert(text_field.exists?)
    end
end