$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Performance < Test::Unit::TestCase
  def setup
    uses_page 'wallofcheckboxes.html'
  end
  
  # http://jira.openqa.org/browse/WTR-216
  # This should take about a quarter of a second. When the bug showed up (because the
  # fast_locate method was broken), it took nearly 10 seconds.
  def test_access_checkbox
    start_time = Time.now
    browser.checkbox(:name, 'custom_monetary_value10:config.admin.required999').set    
    elapsed_time = Time.now - start_time
    assert(elapsed_time < 1.5, 
      "Elapsed time is #{elapsed_time}, should be less than 1.5 seconds.")
  end
  
end
