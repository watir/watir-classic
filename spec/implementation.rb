$LOAD_PATH.unshift File.expand_path("/../lib", File.dirname(__FILE__))
require "watir-classic"

WatirSpec.implementation do |imp|
  imp.name = :watir_classic

  WatirSpec.persistent_browser = false
  imp.browser_class = Watir::IE
  browser = :internet_explorer
  browser_version = "#{browser}#{imp.browser_class.version.to_i}".to_sym

  imp.guard_proc = lambda { |args|
    args.any? {|arg| arg == :watir_classic || arg == [:watir_classic, browser] || arg == browser.to_sym || arg == browser_version || arg == [:watir_classic, browser_version] }
  }
end

include Watir
include Watir::Exception
