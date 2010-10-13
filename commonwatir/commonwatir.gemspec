spec = Gem::Specification.new do |s|
  s.name = 'commonwatir'
  s.version = File.exist?('VERSION') ? File.read('VERSION').strip : "0.0.0"
  s.summary = "Common library for Watir and FireWatir"
  s.description = "Common library for Watir and FireWatir."
  s.author = 'Bret Pettichord'
  s.homepage = 'http://www.watir.com'
  s.email = 'bret@pettichord.com'
  s.rubyforge_project = 'wtr'
  s.require_path = 'lib'

  s.add_dependency 'user-choices'
  s.files = Dir['lib/**/*'] << "Rakefile" << "LICENSE" << "CHANGES" << "VERSION" << "README.rdoc"
  s.test_files = Dir['unittests/**/*']
  s.rdoc_options = ['--main', 'README.rdoc']
  s.extra_rdoc_files = 'README.rdoc'
end
