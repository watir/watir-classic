require 'fileutils'
projects = ['watir', 'firewatir', 'watir-common']

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
task :clean do
  projects.each do |x|
    Dir.chdir(x) {puts `rake.bat clean`}
  end
end