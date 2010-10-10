require 'rubygems'
require 'rake/clean'
require 'fileutils'

projects = ['watir', 'firewatir', 'commonwatir']

def launch_subrake(cmd)
  system("#{Gem.ruby} -S rake #{cmd}")
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

desc "Run tests for Watir and FireWatir"
task :test => [:test_watir, :test_firewatir]

desc 'Run tests for Watir'
task :test_watir do
  Dir.chdir("watir") do
    launch_subrake "test"
  end
end

desc 'Run tests for FireWatir'
task :test_firewatir do
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
