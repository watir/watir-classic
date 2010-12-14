$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_XHTML_Case_Sensitive_Tags < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "a.xhtml"
  end

  def test_html
    # XHTML is case sensitive, so only link 1 is valid.
    # link3 will work if you use ":ID"

    assert browser.link(:id, "link1").exists?, "Could not find link1 by :id"
    assert !browser.link(:id, "link2").exists?, "Found link2 by :id"
    assert !browser.link(:id, "link3").exists?, "Found link3 by :id"
    assert browser.link(:ID, "link3").exists?, "Could not find link3 by :ID"
    assert !browser.link(:id, "link4").exists?, "Found link4 by :id"

    links = browser.links
    assert(links.size == 2, "Links did not find 2 elements")

    links_text = [links[0].text, links[1].text].sort

    assert(links_text[0] == "another lowercase link", "Links did not find link1")
    assert(links_text[1] == "lowercase link", "Links did not find link3")
  end
end
