$__firewatir_source_patterns = [
  'lib/firewatir.rb',
  'lib/firewatir/*.rb',
  'lib/firewatir/elements/*.rb',
  'unittests/*.rb',
  'unittests/html/*.html',
  'unittests/html/images/*.*',
  'LICENSE',
  'CHANGES',
  'rakefile.rb',
  'VERSION',
  'firewatir.gemspec',
  "README.rdoc",
  'LICENSE'
]

spec = Gem::Specification.new do |s|
  version = File.exist?('VERSION') ? File.read('VERSION').strip : "0.0.0"
  s.name = 'firewatir'
  s.version = version
  s.summary = 'Automated testing tool for web applications using Firefox browser.'
  s.description = <<-EOF
    FireWatir stands for "Web Application Testing in Ruby for Firefox". FireWatir (pronounced firewater) is a free, 
    open-source functional testing tool for automating browser-based tests of web applications. 
    It works with applications written in any language.
    FireWatir drives the Firefox browser the same way an end user would. 
    It clicks links, fills in forms, presses buttons. 
    FireWatir also checks results, such as whether expected text appears on the page, or whether a control is enabled.
    FireWatir is a Ruby library that works with Firefox on Windows. It also works on Linux, Mac but without support for
    JavaScript popups (currently support will be there shortly).
  EOF
  s.author = 'Angrez Singh'
  s.homepage = 'http://www.watir.com'
  s.email = 'watir-general@googlegroups.com'
  s.rubyforge_project = 'Watir'

  s.requirements << 'Mozilla Firefox browser 1.5 or later.'
  s.require_path = 'lib'    

  s.add_dependency 'commonwatir', '>=1.9.2'

  s.rdoc_options <<
      '--title' << 'FireWatir API Reference' <<
  		'--accessor' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R' <<
  		'--exclude' << 'unittests|camel_case.rb|testUnitAddons.rb' <<
        '--main' << 'README.rdoc'
  s.extra_rdoc_files = 'README.rdoc'

#  s.test_file  = 'unittests/mozilla_all_tests.rb'

  s.files = $__firewatir_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('CVS')
    }
  }.flatten

end
