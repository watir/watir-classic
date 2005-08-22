$__watir_source_patterns = ['watir.rb', 'watir/*.rb', 'watir/AutoItX3.dll', 'readme.rb',
    'unittests/*.rb', 'unittests/html/*.html', 'unittests/html/images/*.*']

spec = Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = '1.4.1'
  s.summary = 'Automated testing tool for web applications.'
  s.description = <<-EOF
    WATIR stands for "Web Application Testing in Ruby". Watir (pronounced water) is a free, open-source functional testing tool for automating browser-based tests of web applications.
    Watir drives the Internet Explorer browser the same way an end user would. It clicks links, fills in forms, presses buttons. Watir also checks results, such as whether expected text appears on the page.
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
      > regsvr32.exe watir\AutoItX3.dll 
  EOF
  s.require_path = '.'    
  s.autorequire = 'watir'

  s.has_rdoc = true
  # note: duplicated from build-rdoc.bat -- these options should actually be stored in a separate file and then referenced indirectly from both locations.
  s.rdoc_options = ['-t', "Watir API Reference", '-A', "def_wrap=R,def_wrap_guard=R", '-m', 'ReadMe', '-x', "unittests|camel_case.rb|testUnitAddons.rb"]

  s.test_file  = 'unittests/core_tests.rb'

  s.files = $__watir_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('CVS')
    }
  }.flatten

end