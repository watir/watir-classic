$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../commonwatir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../watir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../firewatir/lib")

require "watir"

case ENV['watir_browser']
when /firefox/
  Browser = FireWatir::Firefox
  browser = :firefox
else
  Browser = Watir::IE
  WatirSpec.persistent_browser = true
  browser = :ie
end

WatirSpec.implementation do |imp|
  imp.name = :watir
  imp.guard_proc = lambda { |args|
    args.any? { |arg| arg == :watir || arg == [:watir, browser] }
  }
end


include Watir::Exception
