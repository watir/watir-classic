require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'watir-rdoc'

$VERBOSE = nil
desc 'Generate Watir API Documentation'
Rake::RDocTask.new('rdoc') do |rdoc| 
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options += $WATIR_RDOC_OPTIONS
  rdoc.rdoc_files.include('lib/watir/ie.rb')
  $WATIR_EXTRA_RDOC_FILES.each do |file|
    rdoc.rdoc_files.include(file)
  end
  rdoc.rdoc_files.include('lib/watir/contrib/*.rb')  
  rdoc.rdoc_files.include('lib/watir/*.rb')   
  rdoc.rdoc_files.exclude('lib/watir/camel_case.rb')
end

Rake::TestTask.new do |t|
  t.test_files = FileList['unittests/core_tests.rb']
  t.verbose = true
end

CLEAN << 'pkg' << 'rdoc'

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
