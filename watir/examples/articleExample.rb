require 'watir'
require 'test/unit'

class TC_article_example < Test::Unit::TestCase
 
 def test_search
 
   ie = IE.new

   ie.goto("http://www.google.com")

   ie.textField(:name, "q").set("pickaxe")

   ie.button(:value, "Google Search").click

   assert(ie.pageContainsText("Programming Ruby, 2nd Ed."))

 end

end