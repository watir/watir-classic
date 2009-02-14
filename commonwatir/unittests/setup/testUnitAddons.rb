module Test::Unit::Assertions
    def assert_false(boolean, message=nil)
        _wrap_assertion do
            assert_block("assert should not be called with a block.") { !block_given? }
            assert_block(build_message(message, "<?> is not false.", boolean)) { !boolean }
        end
    end
end # module test
