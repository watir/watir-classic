require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'


BONUS_ZIP = "bonus_files.zip"

$VERBOSE = nil
desc 'Generate Watir API Documentation'
Rake::RDocTask.new('rdoc') do |rdoc| 
  rdoc.title = 'Watir API Reference'
  rdoc.main = 'ReadMe' 
  rdoc.rdoc_dir = 'rdoc'
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

begin
  require 'zip/zip'
rescue LoadError
  puts "rubyzip needs to be installed for the bonus_zip task: gem install rubyzip."
end

desc "Create the bonus files zip"
task :bonus_zip => [:rdoc] do
  if File.exist?(BONUS_ZIP)
    File.delete(BONUS_ZIP)
  end
  Zip::ZipFile::open(BONUS_ZIP, true) { |zf|
    Dir['{doc,rdoc,examples,unittests}/**/*'].each { |f| zf.add(f, f) }
  }
end


else
  puts 'Warning: without Rubygems packaging tasks are not available'
end
