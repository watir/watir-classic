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
=end

class MoTunes::Banner < Borges::Component

  attr_writer :frame

  def initialize(frame, include_search=true)
    @frame = frame
    @include_search = include_search
    @search_text = ''
  end

  def render_banner_on(r)
    r.div_named('title', title)
    r.div_named('subtitle', subtitle)
  end

  def render_content_on(r)
    r.title(title)
    r.table do
      r.table_row do
        if @include_search
          r.element_id('search')
          r.table_data do render_search_on(r) end
        end

        r.element_id('banner')
        r.table_data do render_banner_on(r) end
      end
    end
  end

  def render_search_on(r)
    r.form do
      r.small do
        r.bold('Search: ')
        r.element_id('search_text')
        r.text_input('') do |v| @search_text = v end
        r.default_action do search end
      end
    end
  end

  def search
    @frame.search(@search_text)
  end

  def subtitle
    return 'The tunage that mo likes.'
  end

  def title
    return 'MoTunes'
  end

end

