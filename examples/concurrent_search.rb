# demonstrate ability to run multiple tests concurrently

require 'thread'
require 'watir'  

def test_google
   testSite = 'http://www.google.com'
   ie = Watir::IE.new
   ie.goto(testSite)
   ie.textField(:name, "q").set("pickaxe")    
   ie.button(:value, "Google Search").click   
   ie.close
end

threads = []
3.times do
  threads << Thread.new do
    test_google
  end
end
threads.each {|x| x.join}