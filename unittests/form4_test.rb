# tests for Forms
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Forms4 < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "forms4.html")
    end
    
    def test_find_text_field_ignoring_form
        assert_equal($ie.textField(:name, 'name').getContents, 'apple') # should it raise a not-unique error instead?
    end
    
    def test_correct_form_field_is_found_using_form_name
        assert_equal($ie.form(:name, 'apple_form').textField(:name, 'name').getContents, 'apple')
        assert_equal($ie.form(:name, 'banana_form').textField(:name, 'name').getContents, 'banana')
    end

    def test_correct_form_field_is_found_using_form_index
        assert_equal($ie.form(:index, 1).textField(:name, 'name').getContents, 'apple')
        assert_equal($ie.form(:index, 2).textField(:name, 'name').getContents, 'banana')
    end
end