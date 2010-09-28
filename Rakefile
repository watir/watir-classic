require 'rubygems'
require 'rake/clean'
require 'fileutils'
gem 'ci_reporter'
require 'ci/reporter/rake/test_unit'
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
    tmp_files = %w{CHANGES VERSION}
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

#
# ----------------------------------------------------------------------------
#

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
