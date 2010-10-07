require 'rubygems'
require 'rake/clean'
require 'fileutils'

projects = ['watir', 'firewatir', 'commonwatir']

def launch_subrake(cmd)
  # if Rake.application.unix?
  #   puts `#{$0} #{cmd}`
  # else
  #   puts `rake.bat #{cmd}`
  # end
  # I have left the above commented out because I am not certain that
  # the below works on Windows. If it does, delete the above. If not,
  # uncomment above and delete the below.
  puts `#{$0} #{cmd}`
end

task :default => :gems

task :gemdir do
  mkdir_p "gems" if !File.exist?("gems")
end

desc "Generate all the Watir gems"
task :gems => :gemdir do
  projects.each do |project|
    tmp_files = %w{CHANGES VERSION  README.rdoc LICENSE}
    FileUtils.cp tmp_files, project
    Dir.chdir(project) do
      launch_subrake "gem"
      FileUtils.rm tmp_files
    end
  end
  gems = Dir['*/pkg/*.gem']
  gems.each {|gem| FileUtils.install gem, 'gems'}
end

desc "Clean all the projects"
task :clean_subprojects do
  projects.each do |project|
    Dir.chdir(project) do
      launch_subrake "clean"
    end
  end
end

desc "Clean the build environment and projects"
task :clean => [:clean_subprojects] do
  FileUtils.rm_r Dir.glob("gems/*") << "test/reports", :force => true
end

desc 'Run core_tests tests for IE'
task :core_tests do
  Dir.chdir("watir") do
    launch_subrake "test"
  end
end

desc 'Run mozilla_all_tests for FireFox'
task :mozilla_all_tests do
  Dir.chdir("firewatir") do
    launch_subrake "test"
  end
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
