$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_HTML_Case_Sensitive_Tags < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "a.html"
  end

  def test_html
    # HTML is not case sensitive, so all the links on the page should exist.
    assert browser.link(:id, "link1").exists?, "Could not find link1 by :id"
    assert browser.link(:id, "link2").exists?, "Could not find link2 by :id"
    assert browser.link(:id, "link3").exists?, "Could not find link3 by :id"
    assert browser.link(:id, "link4").exists?, "Could not find link4 by :id"

    links = browser.links
    assert(links.size == 4, "Links did not find 2 elements")

    links_text = [links[0].text, links[1].text, links[2].text, links[3].text].sort

    assert(links_text[0] == "another lowercase link", "Links did not find link3")
    assert(links_text[1] == "another uppercase link", "Links did not find link4")
    assert(links_text[2] == "lowercase link", "Links did not find link1")
    assert(links_text[3] == "uppercase link", "Links did not find link2")
  end
end
