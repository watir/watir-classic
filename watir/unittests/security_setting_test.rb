# The purpose of this test is to verify that IE has been manually
# configured to allow active content from local files.
# This setting is not really required for normal use of Watir, but
# it is essential for many of our unit tests.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_AAA_Security_Settings < Test::Unit::TestCase
  def setup
    uses_page "div.html"
  end

  @@security_instructions = "\
You must change your IE security settings to run these tests.
Tools -> Internet Options -> Advanced -> Security -> 
'Allow active content to run in files on My Computer'"

  def test_active_content
    browser.span(:id, "span3").click
    value = browser.text_field(:name, "text2").value
    fail(@@security_instructions) if value == '0' 
  end
end