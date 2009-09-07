$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../commonwatir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../watir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../firewatir/lib")

require "watir"

case ENV['watir_browser']
when /firefox/
  Browser = FireWatir::Firefox
else
  Browser = Watir::IE
  WatirSpec.persistent_browser = true
end

include Watir::Exception
