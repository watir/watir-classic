# $Id$
=begin
--------------------------------------------------------------------------
Copyright (c) 2002, Chris Morris
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the names Chris Morris, cLabs nor the names of contributors to this
software may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
=end

require 'rbconfig'
require 'find'
require 'ftools'

include Config

$version = CONFIG["MAJOR"]+"."+CONFIG["MINOR"]
$libdir = File.join(CONFIG["libdir"], "ruby", $version)

$bindir =  CONFIG["bindir"]
$sitedir = CONFIG["sitedir"] || File.join($libdir, "site_ruby")
$siteverdir = File.join($sitedir, $version)
$cl_dest = File.join($siteverdir, "cl")
$cliec_dest = File.join($cl_dest, "iec")

def installExecutables(files)
  files.each do |aFile, dest|
    File.open(aFile) do |ip|
      File.open("cliec_tmp", "w") do |op|
        ruby = File.join($bindir, "ruby")
        op.puts "#!#{ruby}"
        op.write ip.read
      end
    end

    File::install("cliec_tmp", File.join(dest, aFile), 0755, true)
    File::unlink("cliec_tmp")
  end
end

def installLib(files)
  files.each do |aFile, dest|
    File::install(aFile, File.join(dest, aFile), 0644, true)
  end
end

if $0 == __FILE__
  File::makedirs($cliec_dest)

  files = { "cliecontroller.rb" => $cliec_dest,
            "iec.rb" => $cl_dest }
  installLib(files)
end
