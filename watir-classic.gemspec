# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'watir-classic'
  s.version = File.read("VERSION").strip
  s.author = 'Bret Pettichord'
  s.email = 'watir-general@groups.google.com'
  s.description = <<-EOF
    The watir-classic gem is no longer being actively maintained.
    As of version 6.0, Watir is implemented with selenium-webdriver.
    If you are requiring watir-classic, update your dependencies to use "watir", "~> 6.0"
  EOF
  s.homepage = 'http://watir.com/'
  s.summary = 'Automated testing tool for web applications.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.requirements << 'Microsoft Windows running Internet Explorer 5.5 or later.'

  s.add_dependency 'win32-process', '>= 0.5.5'
  s.add_dependency 'windows-pr', '>= 0.6.6'
  s.add_dependency 'nokogiri', ">= 1.5.7.rc3"
  s.add_dependency 'ffi', '~>1.0'
  s.add_dependency 'rautomation', '~>0.7'
  s.add_dependency 'multi_json'
  s.add_dependency 'win32screenshot', "~> 2.1.0"

  s.add_development_dependency("rspec", "~>2.3")
  s.add_development_dependency("syntax")
  s.add_development_dependency("yard")
  s.add_development_dependency("sinatra")
  s.add_development_dependency("childprocess")
  s.add_development_dependency('rake')
end
