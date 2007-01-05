require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake/gempackagetask'


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
  rdoc.rdoc_files.include('watir/contrib/*.rb')  
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

desc "Create the bonus files zip"
task :bonus_zip => [:rdoc] do

  begin
    require_gem 'rubyzip'
    require 'zip/zip'
  rescue LoadError
    puts "rubyzip needs to be installed: gem install rubyzip."
    raise
  end
  
  require 'watir'
  version = Watir::IE::VERSION
  bonus_zip = "pkg/watir-bonus-#{version}.zip"

  if File.exist?(bonus_zip)
    File.delete(bonus_zip)
  end
  if !File.directory?("pkg")
    Dir.mkdir("pkg")
  end
  Zip::ZipFile::open(bonus_zip, true) do |zf|
    Dir['{doc,rdoc,examples,unittests}/**/*'].each { |f| zf.add(f, f) }
  end
  
  puts "  Successfully built BonusZip"
  puts "  File: #{bonus_zip}"
  
end


