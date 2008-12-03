# feature tests for title and url

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_MultiplePages < Test::Unit::TestCase
  location __FILE__

end