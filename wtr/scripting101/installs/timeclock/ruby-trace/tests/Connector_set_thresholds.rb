require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"

class Connector_set_thresholds < GlobalTestCase

  # Connecter thresholds are changed with theme_and_destination_use_default.
  # That that works is checked in Threshold.rb.
  # This just does some error handling checks.

  def test_error_handling
    unknown_dest_string = 
      [ "Destination 'buffe' is unknown.",
      "   Try one of these:",
      "   buffer"
      ].join($/)

    assert_trace_exception(unknown_dest_string) {
      $trace.theme_and_destination_use_default("debugging", "buffe", 'error')
    }
    
    unknown_theme_string =
      lines("Theme 'ebugging' is unknown.",
            "   Try one of these:",
            "   debugging")

    assert_trace_exception(unknown_theme_string) {
      $trace.theme_and_destination_use_default("ebugging", "buffer", 'error')
    }
    
    unknown_level_string =
      lines("'erro' is not a level for theme 'debugging'.",
            "   Try one of these:",
            "   none, error, warning, announce, event, debug, verbose")

    assert_trace_exception(unknown_level_string) {
      $trace.theme_and_destination_use_default("debugging", "buffer", 'erro')
    }
    
  end
    
end

