require 'test/unit/assertions'

module Watir
  # Verification methods
  module Assertions
  include Test::Unit::Assertions
    
    # Log a failure if the boolean is true. The message is the failure
    # message logged.
    # Whether true or false, the assertion count is incremented.
    def verify boolean, message = 'verify failed.'
      add_assertion
      add_failure message, caller unless boolean
    end
    
    def verify_equal expected, actual, message=nil
      full_message = build_message(message, <<EOT, expected, actual)
<?> expected but was
<?>.
EOT
      verify(expected == actual, full_message)
    end
    def verify_match pattern, string, message=nil
      pattern = case(pattern)
      when String
        Regexp.new(Regexp.escape(pattern))
      else
        pattern
      end
      full_message = build_message(message, "<?> expected to be =~\n<?>.", string, pattern)
      verify(string =~ pattern, full_message)
    end
    
  end

end