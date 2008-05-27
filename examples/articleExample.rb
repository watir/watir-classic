require 'watir'
require 'test/unit'

class TC_article_example < Test::Unit::TestCase
 
  def test_search
    ie = Watir::IE.new
    ie.goto("http://www.google.com/ncr")
    ie.text_field(:name, "q").set("pickaxe")
    ie.button(:value, "Google Search").click
    assert(ie.text.include?("Programming Ruby: The Pragmatic Programmer's Guide"))
  end

end