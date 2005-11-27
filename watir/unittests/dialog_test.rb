# Feature tests for Dialog class
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/dialog'

class TC_Dialog_Test < Test::Unit::TestCase
    include Watir
    
    def setup
        $ie.goto($htmlRoot  + 'JavascriptClick.html')
    end    
    def teardown
        begin
          dialog.button('OK').click
        rescue
        end
    end
    
    def test_alert_without_bonus_script
        $ie.eval_in_spawned_process <<-END
            button(:id, 'btnAlert').click
        END
        sleep 0.1
        dialog.button("OK").click
        assert_match(/Alert button!/, $ie.text_field(:id, "testResult").value)  
    end

    def test_button_name_not_found
        $ie.eval_in_spawned_process <<-END
            button(:id, 'btnAlert').click
        END
        assert_raises(UnknownObjectException) { dialog.button("Yes").click }
        dialog.button("OK").click
    end
    
    def test_exists
        autoit = WIN32OLE.new('AutoItX3.Control')
        assert_false dialog.exists?
        $ie.eval_in_spawned_process <<-END
            button(:id, 'btnAlert').click
        END
        assert dialog.exists?
        dialog.button('OK').click
    end
    
    def test_leaves_dialog_open
        # should be closed in teardown
        $ie.eval_in_spawned_process <<-END
            button(:id, 'btnAlert').click
        END
    end

    def test_copy_array_elements
        a = ['a', 'b', 'c']
        copy = Array.new(a)
        c = []        
        code = _code_that_copies_readonly_array(a, "c")
        eval code
        assert_equal copy, c
    end

    def test_confirm_ok
        $ie.eval_in_spawned_process <<-END
            button(:value, 'confirm').click
        END
        assert dialog.exists?
        dialog.button('OK').click
        assert_equal "You pressed the Confirm and OK button!", $ie.text_field(:id, 'testResult').value
    end

    def test_confirm_ok
        $ie.eval_in_spawned_process <<-END
            button(:value, 'confirm').click
        END
        assert dialog.exists?
        dialog.button('Cancel').click
        assert_equal "You pressed the Confirm and OK button!", $ie.text_field(:id, 'testResult').value
    end
    
end