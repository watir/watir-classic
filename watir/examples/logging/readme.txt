These are examples of how to integrate logging with Watir. Watir uses "logger", 
which is included in the Ruby library when you install Ruby.

Example 1:
----------
example_logger1.rb uses inheritance from watir::logger and from logger. A 
default logger is created which writes all "log" method calls to a text file
prefixed by "test_logger1". The example test: test_logger1.rb uses the default
"core" logger, and also creates an XML Logger object which logs the test results
to an XML log file also prefixed by "test_logger1".