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

class MoTunes::Cart < Borges::Component
  def remove(item)
    session.cart.delete(item)
  end

  def render_content_on(r)
    return self unless session.has_cart?

    r.div_named('cart') do
      r.small do r.bold('Your cart: ') end

      r.table do
        render_album_row_titles(r)
        grand_total = 0
        session.cart.each do |item, count| 
          total = (count * item.price)
          grand_total += total
          render_album_row(r, item, count, total.to_cents)
        end

        r.table_spacer_row
        render_album_grand_total(r, grand_total.to_cents)
      end
    end
  end

  def render_album_row(r, album, count, total)
    r.table_row do
      r.table_data do
        r.small do
          r.element_id('remove_' + album.name)
          r.anchor('x') do
            remove(album)
          end 
        end
      end
      r.table_data do r.small do r.text(album.name) end end
      r.table_data do r.small do r.text(count) end end
      r.table_data do r.small do r.text(total) end end
    end
  end
  
  def render_album_row_titles(r)
    r.table_row do
      r.table_data do r.space end
      r.table_data do r.small do r.bold('Album') end end
      r.table_data do r.small do r.bold('Qty') end end
      r.table_data do r.small do r.bold('Total') end end
    end
  end
  
  def render_album_grand_total(r, grand_total)
    r.table_row do
      r.table_data do r.space end
      r.table_data do r.space end
      r.table_data do r.space end
      r.table_data do r.small do r.bold(grand_total) end end
    end
  end
end

