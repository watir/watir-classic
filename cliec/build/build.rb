require 'cl/util/console'
require 'cl/util/file'
require 'cl/util/version'
require 'ftools'
require 'fileutils'
require 'cl/util/win'
require 'install'

def zipfn
  File.join('../dist', "iec.#{@v.to_s}.zip")
end

def dl_url
  "http://clabs.org/dl/iec/#{File.basename(zipfn)}"
end

root_dir = './iec'

BUILD_MANIFEST = {
  'install.rb'   => root_dir,
  '../src/**/*'  => File.join(root_dir, 'src'),
  '../doc/*'     => File.join(root_dir, 'doc'),
  '../example/*' => File.join(root_dir, 'example')
}

@v = CLabs::Version.new(
  Time.now.strftime("%Y"),
  Time.now.strftime("%j"),
  0
)
@v.write_version_header('../src/iec/cliecontroller.rb')

File.makedirs root_dir
copy_files(BUILD_MANIFEST)

Dir[File.join('../dist', '*.zip')].each do |fn| File.delete(fn) end
File::makedirs('../dist')
system("zip -r #{zipfn} #{root_dir}")
sleep 2
ClUtilFile.delTree(root_dir)

clabs_build = if_switch('-clabs')
if clabs_build
  puts "updating scrplist.xml..."
  fsize = (File.size("#{zipfn}") / 1000).to_s + 'k'
  require 'c:/dev/cvslocal/cweb/clabs/scrplist.rb'
  slist = get_slist
  slist.groups.each do |group|
    group.items.each do |sitem|
      if sitem.name =~ /Internet Explorer Controller/
        sitem.version = @v.to_s
        sitem.date = Time.now.strftime("%m/%d/%Y")
        dl = sitem.downloads[0]
        dl.name = File.basename(zipfn)
        dl.link = dl_url
        dl.size = fsize
      end
    end
  end
  write_slist(slist)

  puts "copying .zip to clabs dist..."
  cp_dest_dir = "c:/dev/cvslocal/cweb/clabs/bin/dl/iec"
  File.makedirs(cp_dest_dir)
  File.copy "#{zipfn}", File.join(cp_dest_dir, "#{File.basename(zipfn)}")
  system('pause')
end
