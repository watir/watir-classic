# $Id$
=begin
----------------------------------------------------------------------------
Copyright (c) 2002-2003, Chris Morris
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

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
----------------------------------------------------------------------------
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

INSTALL_MANIFEST = {
  './src/**/*'  => $cl_dest,
  './doc/*'     => File.join($cliec_dest, 'doc'),
  './example/*' => File.join($cliec_dest, 'example')
}

def copy_files(file_patterns)
  file_patterns.each do |fn_pattern, dest_dir|
    Dir[fn_pattern].each do |fn|
      if File.file?(fn) && !fn.include?('CVS')
        # this is really confusing, i know what I need, but don't know
        # any clear terms to make the code readable
        if fn_pattern.include?('*')
          fn_pat_root = fn_pattern[0..(fn_pattern.index('*')-1)]
          dest_subdir = fn.sub(/#{fn_pat_root}/, '')
        else
          dest_subdir = fn
        end
        destfn = File.join(dest_dir, dest_subdir)
        File::makedirs(File.dirname(destfn))
        puts 'copying from ' + fn + '...' if $DEBUG
        puts 'writing ' + destfn + '...'
        File.copy fn, destfn
      end
    end
  end
end

if $0 == __FILE__
  copy_files(INSTALL_MANIFEST)
end
