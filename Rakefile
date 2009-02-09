require 'rubygems'
require 'rake/clean'
require 'ftools'
require 'fileutils'
require 'rake/testtask'
gem 'ci_reporter'
require 'ci/reporter/rake/test_unit'
projects = ['watir', 'firewatir', 'commonwatir']
 
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

desc 'Run core_tests tests for IE'
Rake::TestTask.new :core_tests do |t|
  t.test_files = FileList['watir/unittests/core_tests.rb']
  t.verbose = true
end

desc 'Run mozilla_all_tests for FireFox'
Rake::TestTask.new :mozilla_all_tests do |t|
  t.test_files = FileList['firewatir/unittests/mozilla_all_tests.rb']
  t.verbose = true
end

namespace :cruise do
  def move_reports(report_dir)
    Dir[report_dir].each { |e| File::move(e, ENV['CC_BUILD_ARTIFACTS']) }
    File::copy("transform-results.xsl", ENV['CC_BUILD_ARTIFACTS'])
    add_style_sheet_to_reports(ENV['CC_BUILD_ARTIFACTS'] + '/*.xml')
  end
    
  def add_style_sheet_to_reports(report_dir)
    dir_arr = Dir[report_dir]
    return if dir_arr.empty
    dir_arr.each do |f|
      sContent = File.readlines(f, '\n')
      sContent.each do |line|
        line.sub!(/<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>/, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text\/xsl\" href=\"transform-results.xsl\"?>")
      end
      xmlFile = File.open(f, "w+")
      xmlFile.puts sContent
      xmlFile.close
    end
  end
  
  task :move_reports_ie do
    move_reports "watir/test/reports/*.xml"
  end
  task :move_reports_ff do
    move_reports "firewatir/test/reports/*.xml"
  end
  
  task :ie_core_tests => ['ci:setup:testunit', :core_tests, :move_reports_ie]
  task :ff_mozilla_all_tests => ['ci:setup:testunit', :mozilla_all_tests, :move_reports_ff]
end

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

desc 'Run tests for all browser'
task :test => [:test_ie, :test_ff]
