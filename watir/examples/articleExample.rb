require 'watir'
include Watir
require 'test/unit'

class TC_article_example < Test::Unit::TestCase
 
  def test_search
    ie = IE.new
    ie.goto("http://www.google.com")
    ie.text_field(:name, "q").set("pickaxe")
    ie.button(:value, "Google Search").click
    assert(ie.contains_text("Programming Ruby, 2nd Ed."))
  end

end