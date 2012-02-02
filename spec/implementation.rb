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
    WatirSpec.persistent_browser = false
    imp.browser_class = Watir::IE
    browser = :ie
    browser_version = "ie#{imp.browser_class.version.to_i}".to_sym
  end

  imp.guard_proc = lambda { |args|
    args.any? {|arg| arg == :watir || arg == [:watir, browser] || arg == :ie || arg == browser_version || arg == [:watir, browser_version] }
  }
end

include Watir
include Watir::Exception
