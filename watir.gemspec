require 'watir-rdoc'

$__watir_source_patterns = [
    'watir.rb', 'watir/*.rb', 'watir/AutoItX3.dll', 
    'unittests/*.rb', 'unittests/html/*.html', 'unittests/html/images/*.*', 
    'unittests/other/*.rb', 'unittests/testcase/*.rb', 'unittests/windows/*.rb',
    'watir/IEDialog/Release/IEDialog.dll', 'watir/win32ole/win32ole.so', 
    'watir/contrib/*.rb'] +  
    $WATIR_EXTRA_RDOC_FILES

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'watir'

spec = Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = Watir::IE::VERSION
  s.summary = 'Automated testing tool for web applications.'
  s.description = <<-EOF
    WATIR is "Web Application Testing in Ruby". Watir (pronounced water) is a free, 
    open-source functional testing tool for automating browser-based tests of web applications. 
    It works with applications written in any language.
    Watir drives the Internet Explorer browser the same way an end user would. 
    It clicks links, fills in forms, presses buttons. 
    Watir also checks results, such as whether expected text appears on the 
    page, or whether a control is enabled.
    Watir can test web applications written in any language. 
    Watir is a Ruby library that works with Internet Explorer on Windows.
  EOF
  s.author = 'Bret Pettichord'
  s.email = 'wtr-general@rubyforge.org'
  s.rubyforge_project = 'Web Testing with Ruby'
  s.homepage = 'http://wtr.rubyforge.org/'

  s.platform = Gem::Platform::RUBY
  s.requirements << 'Microsoft Windows running Internet Explorer 5.5 or later.'
  s.require_path = '.'    
  s.autorequire = 'watir'
  s.add_dependency("win32-process", ">= 0.5.2")

  s.has_rdoc = true
  s.rdoc_options += $WATIR_RDOC_OPTIONS

  s.test_file  = 'unittests/core_tests.rb'

  s.files = $__watir_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('CVS')
    }
  }.flatten

end