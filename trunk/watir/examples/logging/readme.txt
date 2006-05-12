These are examples of how to integrate logging with Watir. Watir uses "logger", 
which is included in the Ruby library when you install Ruby. -Jonathan Kohl

If you make improvements to this example, please share them with the wtr-general
mailing list.

Example 1:
----------
This example logs to a default log file that catches any log method calls in 
Watir itself or in any test cases, and logs results to an XML file. This is a
very simple example that does minimal XML logging by creating the tags in methods
within the example_logger1.rb file.

example_logger1.rb uses inheritance from watir::logger and from logger. A 
default logger is created which writes all "log" method calls to a text file
prefixed by "test_logger1". The example test: test_logger1.rb uses the default
"core" logger, and also creates an XML Logger object which logs the test results
to an XML log file also prefixed by "test_logger1".

When "test_logger1" is run, it will create two log files in the same directory:
test_logger1_<date>.txt
test_logger1_<date>.xml