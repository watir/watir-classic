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
require 'google.cliec'

# Google's result page doesn't have ideal html for automation. cliec assists
# with this scenario by providing DOM helper classes. The following script
# executes the previous Google example, then uses the DOM Viewer to dump
# the complete paths to each object in the DOM tree. 

dv = ClIEDomViewer.new(@iec)
File.open('google.dom.dump.txt', 'w') do |f| dv.outputDom(f) end
@iec.close

# Digging through google.dom.dump.txt, we can find the first link here:
#
# [snip]
# nodeName: -HTML-BODY1-DIV1-P1-A1
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text1
# nodeValue: RubyForge: Project Info- 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B1
# nodeName: -HTML-BODY1-DIV1-P1-A1-B1-#text1
# nodeValue: Web
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text2
# nodeValue:# 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B2
# nodeName: -HTML-BODY1-DIV1-P1-A1-B2-#text1
# nodeValue: Testing
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text3
# nodeValue:# with 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B3
# nodeName: -HTML-BODY1-DIV1-P1-A1-B3-#text1
# nodeValue: Ruby
# [snip]
#
# so, we now have a path to the first link: "-HTML-BODY1-DIV1-P1-A1" and we
# can use this in a subsequent script --> see google.cliec.link.click.rb
