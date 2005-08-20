$__watir_source_patterns = ['watir.rb', 'watir/*.rb', 'watir/AutoItX3.dll', 'readme.txt']

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'watir'
  s.version = '1.4.1'
  s.summary = 'Automated testing tool for web applications.'
  s.description = <<-EOF
    "Watir" (pronounced water) stands for "Web Application Testing in Ruby". Watir is a free open source functional testing library for automated tests to be developed and run against a web browser.
    Watir can drive a web browser the way an end user would. It can click on links, fill in forms, press buttons etc. Watir also lets you check results. For example, you can check whether certain text appears on the page, so you can take the appropriate action.
    Currently only Internet Explorer is supported, but work is underway to support other browsers.
  EOF
  s.author = 'Paul Rogers, Bret Pettichord'
  s.email = 'wtr-general@rubyforge.org'
  s.rubyforge_project = 'Web Testing with Ruby'
  s.homepage = 'http://wtr.rubyforge.org/'

  s.has_rdoc = false
  
  s.requirements << 'none'
  s.require_path = '.'

  s.files = $__watir_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('CVS')
    }
  }.flatten
  s.autorequire = 'watir'

end
