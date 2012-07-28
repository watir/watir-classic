$LOAD_PATH.unshift File.expand_path("/../lib", File.dirname(__FILE__))
require "watir-classic"

WatirSpec.implementation do |imp|
  imp.name = :watir_classic

  WatirSpec.persistent_browser = false
  imp.browser_class = Watir::IE
  browser = :ie
  browser_version = "ie#{imp.browser_class.version.to_i}".to_sym

  imp.guard_proc = lambda { |args|
    args.any? {|arg| arg == :watir_classic || arg == [:watir_classic, browser] || arg == :ie || arg == browser_version || arg == [:watir_classic, browser_version] }
  }
end

include Watir
include Watir::Exception
