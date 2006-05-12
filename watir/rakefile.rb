require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'

$VERBOSE = nil

desc 'Generate Watir API Documentation'
Rake::RDocTask.new('rdoc') do |rdoc| 
  rdoc.title = 'Watir API Reference'
  rdoc.main = 'ReadMe' 
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '-A' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R'
  rdoc.rdoc_files.include('watir.rb')
  rdoc.rdoc_files.include('readme.rb')
  rdoc.rdoc_files.include('watir/*.rb')
  rdoc.rdoc_files.exclude('watir/camel_case.rb')
  rdoc.rdoc_files.exclude('watir/testUnitAddons.rb')
end

CLEAN << 'pkg' << 'html'

desc 'Run all tests'
task :default => :package

desc 'Build the one-click installer'
file 'installer/watir_installer.exe' do
  Dir.chdir 'installer'
  system('c:\program files\nsis\makensis watir_installer.nsi')
end
task :one_click => ['installer/watir_installer.exe']


begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception => e
  nil
end

if defined? Rake::GemPackageTask

  gemspec = eval(File.read('watir.gemspec'))

  Rake::GemPackageTask.new(gemspec) do |p|
    p.gem_spec = gemspec
    p.need_tar = false
    p.need_zip = false
  end

else
  puts 'Warning: without Rubygems packaging tasks are not available'
end