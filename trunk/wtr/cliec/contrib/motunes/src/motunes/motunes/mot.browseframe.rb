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

class MoTunes::BrowseFrame < Borges::Component
  def actions
    actions = [:home, :browse]

    if session.has_cart? then
      actions << :checkout
    else
      actions
    end
  end

  def browse
    @main.call(MoTunes::ArtistList.new(session.all_items))
  end

  def checkout
    answer
  end

  def home
    @main.clear_delegate 
  end

  def initialize
    @main = MoTunes::Front.new

    @navbar = Borges::NavigationBar.new(self)

    @cart = MoTunes::Cart.new

    @banner = MoTunes::Banner.new(self)
  end

  def render_content_on(r)
    r.table do
      r.element_id('top')

      r.table_row_span(3) do @banner.render_on(r) end

      r.table_spacer_row

      r.table_row do
        r.element_id('nav')
        r.table_data do @navbar.render_on(r) end

        r.element_id('main')
        r.table_data do @main.render_on(r) end

        r.element_id('side')
        r.table_data do @cart.render_on(r) end
      end
    end
  end

  def search(search_string)
    home
    @main.call(MoTunes::SearchTask.new(search_string))
  end

  def style
    session.style
  end

end

