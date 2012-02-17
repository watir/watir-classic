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

# To run a single test form the unittests directory (e.g.
# unittests/checkbox_test.rb), you can do:
# rake run_single_test[checkbox_test.rb]
task :run_single_test, [:test_file] do |t,args|
  if !args.test_file
    puts "usage: rake run_single_test[file.rb]"
    exit
  end

  require 'unittests/setup'
  require 'unittests/'+args.test_file

  # usually, when running a single test, i want to be able to look at the browser,
  # so a dirty hack here is to override the close method on $browser.
  def $browser.close
  end
end
