require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'


BONUS_DIR = 'bonus_files'
BONUS_DIR_FULL = File.join(File.dirname(__FILE__), BONUS_DIR)
ZIP_DIRS = FileList["doc", "rdoc", "examples", "unittests"].exclude(/\.svn/)	

$VERBOSE = nil
desc 'Generate Watir API Documentation'
Rake::RDocTask.new('rdoc') do |rdoc| 
  rdoc.title = 'Watir API Reference'
  rdoc.main = 'ReadMe' 
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options << '-A' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R'
  rdoc.rdoc_files.include('watir.rb')
  rdoc.rdoc_files.include('readme.rb')
  rdoc.rdoc_files.include('watir/*.rb')
  rdoc.rdoc_files.exclude('watir/camel_case.rb')
  rdoc.rdoc_files.exclude('watir/testUnitAddons.rb')
end

CLEAN << 'pkg' << 'html'

desc 'Run all tests'
task :default => :package

desc 'Build the one-click installer'
file 'installer/watir_installer.exe' do
  Dir.chdir 'installer'
  system('c:\program files\nsis\makensis watir_installer.nsi')
end
task :one_click => ['installer/watir_installer.exe']


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
    p.need_tar = false
    p.need_zip = false
  end

class Dir
  def copy_to(dest_dir)
    src_dir = Pathname.new(self.path)
    dest_dir = Pathname.new(dest_dir)
    FileList["#{src_dir}/**/*"].each do |src|
      next if File.directory?(src)
      dest = dest_dir + Pathname.new(src)
      mkdir_p dest.dirname.to_s
      cp(src, dest) unless uptodate?(dest + src, src)
    end
  end
end

desc "Create the bonus files zip"
task :bonus_zip => [ :rdoc ] do
	rm_rf BONUS_DIR_FULL
	mkdir BONUS_DIR_FULL
	ZIP_DIRS.each do |d|	
		Dir.new("#{d}").copy_to(BONUS_DIR_FULL)
	end

  system %{zip -r bonusfiles.zip #{BONUS_DIR}}
end

else
  puts 'Warning: without Rubygems packaging tasks are not available'
end