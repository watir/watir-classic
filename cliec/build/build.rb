=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2001-2004, Chris Morris
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Chris Morris, cLabs nor the names of contributors to
  this software may be used to endorse or promote products derived from this
  software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  --------------------------------------------------------------------------
  (based on BSD Open Source License)
  ------------
  CONTRIBUTORS
  ------------
  Jonathon Kohl
  Brian Marick
  Bret Pettichord
  Paul Rogers
=end
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
  'install.rb'                    => root_dir,
  '../src/**/*'                   => File.join(root_dir, 'src'),
  '../doc/*'                      => File.join(root_dir, 'doc'),
  '../example/*'                  => File.join(root_dir, 'example'),
  '../contrib/motunes/**/*'       => File.join(root_dir, 'contrib/motunes'),
  '../contrib/mozaxc/**/*'       => File.join(root_dir, 'contrib/mozaxc')
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
