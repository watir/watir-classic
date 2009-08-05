require 'rubygems'
require 'rake/clean'
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
CLEAN << 'gems/*' << 'test/reports'

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
  def add_style_sheet_to_reports(report_dir)
    Dir[report_dir].each do |f|
      sContent = File.readlines(f, '\n')
      sContent.each do |line|
        line.sub!(/<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>/, 
          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text\/xsl\" href=\"transform-results.xsl\"?>")
      end
      File.open(f, "w+") { |file| file.puts sContent }
    end
  end
  
  task :move_reports do
    reports = "test/reports/*.xml"
    add_style_sheet_to_reports(reports)
    FileUtils.cp("transform-results.xsl", "test/reports")
    if ENV['CC_BUILD_ARTIFACTS']
      Dir[reports].each { |e| FileUtils.cp(e, ENV['CC_BUILD_ARTIFACTS']) }
      FileUtils.cp("transform-results.xsl", ENV['CC_BUILD_ARTIFACTS'])
    else
      puts "Build results not copied. CC_BUILD_ARTIFACTS not defined"
    end
  end
  
  task :verbose do
    # ci:setup_testunit also mucks with this
    ENV["TESTOPTS"] = "#{ENV["TESTOPTS"]} -v"
  end
  
  desc 'Run tests for Internet Explorer'
  task :ie_core_tests => ['ci:setup:testunit', :verbose, :core_tests, :move_reports]
  desc 'Run tests for Firefox'
  task :ff_mozilla_all_tests => ['ci:setup:testunit', :verbose, :mozilla_all_tests, :move_reports]
  
  desc 'Run all tests'
  task :all => [:ie_core_tests, :ff_mozilla_all_tests]
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
