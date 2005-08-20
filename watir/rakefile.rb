require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'

$VERBOSE = nil

# Standard Rails tasks

# Additional tasks (not standard Rails)
CLEAN << 'pkg' << 'html'

desc 'Run all tests'
task :default => :package

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
    p.need_tar = true
    p.need_zip = true
  end

else
  puts 'Warning: without Rubygems packaging tasks are not available'
end