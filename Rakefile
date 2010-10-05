require 'rubygems'
require 'rake/clean'
require 'fileutils'

projects = ['watir', 'firewatir', 'commonwatir']

desc "Generate all the Watir gems"
task :gems do
  projects.each do |project|
    tmp_files = %w{CHANGES VERSION  README.rdoc}
    FileUtils.cp tmp_files, project
    Dir.chdir(project) do
      puts `rake.bat gem`
      FileUtils.rm tmp_files
    end
  end
  FileUtils.makedirs 'gems'
  gems = Dir['*/pkg/*.gem']
  gems.each {|gem| FileUtils.install gem, 'gems'}
end

desc "Clean all the projects"
task :clean_subprojects do
  projects.each do |x|
    Dir.chdir(x) {puts `rake.bat clean`}
  end
end

task :clean => [:clean_subprojects] do
  FileUtils.rm_r Dir.glob("gems/*") << "test/reports", :force => true
end

desc 'Run core_tests tests for IE'
task :core_tests do
  Dir.chdir("watir") {system "call rake.bat test"}
end

desc 'Run mozilla_all_tests for FireFox'
task :mozilla_all_tests do
  Dir.chdir("firewatir") {system "call rake.bat test"}
end

#
# ------------------------------ watirspec -----------------------------------
#

if File.exist?(path = "spec/watirspec/watirspec.rake")
  load path
end

namespace :watirspec do
  desc 'Initialize and fetch the watirspec submodule'
  task :init do
    sh "git submodule init"
    sh "git submodule update"
  end
end
