require 'rubygems'
require 'rake/clean'
require 'fileutils'
require 'rake/testtask'
gem 'ci_reporter'
require 'ci/reporter/rake/test_unit'
projects = ['watir', 'firewatir', 'commonwatir']
ENV['CI_REPORTS'] = ENV['CC_BUILD_ARTIFACTS']

desc "Generate all the Watir gems"
task :gems do
  projects.each do |x|
    Dir.chdir(x) {puts `rake.bat gem`}
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

task :clean => [:clean_subprojects]
CLEAN << 'gems/*'

desc 'Run unit tests for IE'
Rake::TestTask.new :test_ie do |t|
  t.test_files = FileList['watir/unittests/core_tests.rb']
  t.verbose = true
end

desc 'Run unit tests for FireFox'
task :test_ff do
  load 'firewatir/unittests/mozilla_all_tests.rb' 
end

task :cruise => ['ci:setup:testunit', :test_ie]

desc 'Build the html for the website (wtr.rubyforge.org)'
task :website do
  Dir.chdir 'doc' do
    puts system('call webgen -V 1')
  end
end

desc 'Build and publish the html for the website at wtr.rubyforge.org'
task :publish_website => [:website] do
  user = 'bret' # userid on rubyforge
  puts system("call pscp -v -r doc\\output\\*.* #{user}@rubyforge.org:/var/www/gforge-projects/wtr")
end