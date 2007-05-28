require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'watir-rdoc'

$VERBOSE = nil
desc 'Generate Watir API Documentation'
Rake::RDocTask.new('rdoc') do |rdoc| 
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options += $WATIR_RDOC_OPTIONS
  rdoc.rdoc_files.include('watir.rb')
  rdoc.rdoc_files.include('readme.rb') 
  rdoc.rdoc_files.include('changes.rb') 
  rdoc.rdoc_files.include('license.rb') 
  
end

desc 'Rdoc all files including watir/* and the contrib files'
Rake::RDocTask.new('rdoc_all') do |rdoc_all| 
  rdoc_all.rdoc_dir = 'rdoc-all'
  rdoc_all.options += $WATIR_RDOC_OPTIONS
  rdoc_all.rdoc_files.include('watir.rb')
  rdoc_all.rdoc_files.include('readme.rb')
  rdoc_all.rdoc_files.include('changes.rb')
  rdoc_all.rdoc_files.include('license.rb')
  rdoc_all.rdoc_files.include('watir/contrib/*.rb')  
  rdoc_all.rdoc_files.include('watir/*.rb')   
  rdoc_all.rdoc_files.exclude('watir/camel_case.rb')
  rdoc_all.rdoc_files.exclude('watir/testUnitAddons.rb')  
end

CLEAN << 'pkg' << 'html'

desc 'Run all tests'
task :default => :package

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


