# demonstrate ability to run multiple tests concurrently

require 'thread'
require 'watir'  

def test_google
  ie = Watir::IE.start('http://www.google.com')
  ie.text_field(:name, "q").set("pickaxe")    
  ie.button(:value, "Google Search").click   
  ie.close
end

# run the same test three times concurrently in separate browsers
threads = []
3.times do
  threads << Thread.new {test_google}
end
threads.each {|x| x.join}