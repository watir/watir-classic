# Prevent assertion failures from killing IRB

require 'test/unit/assertions'
module Test
  module Unit
    remove_const(:AssertionFailedError) # to avoid warning
    class AssertionFailedError < RuntimeError
    end
  end
end
include Test::Unit::Assertions

