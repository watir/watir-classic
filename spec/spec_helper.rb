$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../commonwatir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../watir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../firewatir/lib")

require "watir"

WatirSpec.implementation do |imp|
  imp.name = :watir

  if ENV['watir_browser'] =~ /firefox/
    imp.browser_class = FireWatir::Firefox
    browser = :firefox
  else
    WatirSpec.persistent_browser = true
    imp.browser_class = Watir::IE
    browser = :ie
  end

  imp.guard_proc = lambda { |args|
    args.any? { |arg| arg == :watir || arg == [:watir, browser] }
  }
end

include Watir::Exception
