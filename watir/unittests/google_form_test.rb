# defect report from users of Watir Recorder
# revision: $Revision: 746 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_GoogleForm < Test::Unit::TestCase
  
  def setup
    goto_page "google_india.html"
  end
  
  def test_it
    browser.form(:name, "f").text_field(:name, "q").set("ruby")
  end
end