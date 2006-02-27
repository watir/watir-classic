$__watir_source_patterns = ['watir.rb', 'watir/*.rb', 'watir/AutoItX3.dll', 'readme.rb',
    'unittests/*.rb', 'unittests/html/*.html', 'unittests/html/images/*.*', 
    'watir/IEDialog/Release/IEDialog.dll', 'watir/win32ole/win32ole.so']

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'watir'

spec = Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = Watir::IE::VERSION
  s.summary = 'Automated testing tool for web applications.'
  s.description = <<-EOF
    WATIR stands for "Web Application Testing in Ruby". Watir (pronounced water) is a free, 
    open-source functional testing tool for automating browser-based tests of web applications. 
    It works with applications written in any language.
    Watir drives the Internet Explorer browser the same way an end user would. 
    It clicks links, fills in forms, presses buttons. 
    Watir also checks results, such as whether expected text appears on the page, or whether a control is enabled.
    Watir can test web applications written in any language. 
    Watir is a Ruby library that works with Internet Explorer on Windows.
  EOF
  s.author = 'Paul Rogers, Bret Pettichord'
  s.email = 'wtr-general@rubyforge.org'
  s.rubyforge_project = 'Web Testing with Ruby'
  s.homepage = 'http://wtr.rubyforge.org/'

  s.platform = Gem::Platform::RUBY
  s.requirements << 'Microsoft Windows running Internet Explorer 5.5 or later.'
  s.requirements << <<-EOF
    Some Watir features require that an included DLL be registered. You'll have to do this manually:
      > regsvr32.exe watir\\AutoItX3.dll 
  EOF
  s.require_path = '.'    
  s.autorequire = 'watir'

  s.has_rdoc = true
  s.rdoc_options << 
        '--title' << 'Watir API Reference' <<
  		'--accessor' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R' <<
  		'--main' << 'ReadMe' << 
  		'--exclude' << 'unittests|camel_case.rb|testUnitAddons.rb'
  s.extra_rdoc_files = 'readme.rb'

  s.test_file  = 'unittests/core_tests.rb'

  s.files = $__watir_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('CVS')
    }
  }.flatten

end