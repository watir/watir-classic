# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'watir-classic'
  s.version = File.read("VERSION").strip
  s.author = 'Bret Pettichord'
  s.email = 'watir-general@groups.google.com'
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
  s.homepage = 'http://watir.com/'
  s.summary = 'Automated testing tool for web applications.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]  
  s.requirements << 'Microsoft Windows running Internet Explorer 5.5 or later.'

  s.add_dependency 'win32-process', '>= 0.5.5'
  s.add_dependency 'windows-pr', '>= 0.6.6'
  s.add_dependency 'nokogiri'
  s.add_dependency 'ffi', '~>1.0'
  s.add_dependency 'rautomation', '~>0.7.2'
  s.add_dependency 'user-choices'
  s.add_dependency 'multi_json'
  s.add_dependency 'win32screenshot'

  s.add_development_dependency("rspec", "~>2.3")
  s.add_development_dependency("syntax")
  s.add_development_dependency("yard")
  s.add_development_dependency("sinatra")
  s.add_development_dependency("childprocess")
end
