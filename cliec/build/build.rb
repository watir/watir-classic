require 'cl/util/file'
require 'cl/util/version'
require 'ftools'
require 'cl/util/win'

@v = CLabs::Version.new(
  Time.now.strftime("%Y"),
  Time.now.strftime("%j"),
  0
)

def zipfn
  "iec.#{@v.to_s}.zip"
end

def dl_url
  "http://clabs.org/dl/iec/#{zipfn}"
end

raise "I started a re-org, but haven't tried all this out yet..."

@v.write_version_header('cliecontroller.rb')
Dir['*.zip'].each do |fn| File.delete(fn) end
root_dir = './iec'
File.makedirs root_dir
iec_files = ['install.rb', '../src/iec.rb', '../src/cliecontroller.rb', '../doc/Readme']
iec_files.each do |f| File.copy f, File.join(root_dir, File.basename(f)) end
system("zip -r #{zipfn} #{root_dir}")
sleep 2
ClUtilFile.delTree(root_dir)

clabs_build = false
if clabs_build
  puts "updating scrplist.xml..."
  fsize = (File.size("#{zipfn}") / 1000).to_s + 'k'
  require 'f:/dev/cvslocal/cweb/clabs/scrplist.rb'
  slist = get_slist
  slist.groups.each do |group|
    group.items.each do |sitem|
      if sitem.name =~ /cLabs IEController/
        sitem.version = @v.to_s
        sitem.date = Time.now.strftime("%m/%d/%Y")
        dl = sitem.downloads[0]
        dl.name = zipfn
        dl.link = dl_url
        dl.size = fsize
      end
    end
  end
  write_slist(slist)
end

if clabs_build
  puts "copying .zip to clabs dist..."
  cp_dest_dir = "f:/dev/cvslocal/cweb/clabs/bin/dl/iec"
  File.makedirs(cp_dest_dir)
  File.copy "#{zipfn}", File.join(cp_dest_dir, "#{zipfn}")
  system('pause')
end
