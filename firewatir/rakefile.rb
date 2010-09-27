require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/gempackagetask'

task :default => :package

CLEAN << 'pkg' << 'rdoc'

gemspec = eval(File.read('firewatir.gemspec'))
Rake::GemPackageTask.new(gemspec) do |p|
  p.gem_spec = gemspec
  p.need_tar = false
  p.need_zip = false
end

Rake::TestTask.new do |t|
  t.test_files = FileList['unittests/mozilla_all_tests.rb']
  t.verbose = true
end