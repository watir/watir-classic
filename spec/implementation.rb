$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../commonwatir/lib")
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../watir-classic/lib")

require "watir-classic"

WatirSpec.implementation do |imp|
  imp.name = :watir

  WatirSpec.persistent_browser = false
  imp.browser_class = Watir::IE
  browser = :ie
  imp.browser_args = [browser]
  browser_version = "ie#{imp.browser_class.version.to_i}".to_sym

  imp.guard_proc = lambda { |args|
    args.any? {|arg| arg == :watir || arg == [:watir, browser] || arg == :ie || arg == browser_version || arg == [:watir, browser_version] }
  }
end

include Watir
include Watir::Exception
