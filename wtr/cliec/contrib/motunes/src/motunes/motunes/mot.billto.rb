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

class MoTunes::BillToView < Borges::Component
  def initialize(frame, editable=true)
    @frame = frame
    @editable = editable
    @bill_to = session.bill_to
    @ship_to = session.ship_to
    @ship_is_bill = false
  end

  def update_ship_address
    $stderr.puts '@ship_is_bill: ' + @ship_is_bill.inspect
    if @ship_is_bill
      @ship_to = @bill_to.dup
    end
    $stderr.puts @ship_to.inspect
  end
  
  def render_content_on(r)
    r.form do
      r.table do
        r.table_row do
          r.table_data do
            @bill_to.render_on(r, @editable)
          end
          r.table_data do
            @ship_to.render_on(r, !@ship_is_bill && @editable)
          end
        end
        r.table_row do
          r.set_attribute('align', 'center')
          r.table_data do 
            r.small do r.text('Shipping address same as billing:') end
            r.element_id('ship_is_bill')
            r.checkbox(@ship_is_bill) do |new_ship_is_bill|
              $stderr.puts 'new_ship_is_bill=' + new_ship_is_bill.inspect
              @ship_is_bill = new_ship_is_bill
              update_ship_address
            end
          end
        end
      end
      
      r.submit_button_on(:submit, self) if @editable
    end
  end
  
  def submit
    update_ship_address
    @frame.submit
  end
end

class MoTunes::Widget
  attr_accessor :name, :value
  
  def initialize(name, value=nil)
    @name = name
    @value = value
  end
  
  def render_on(r, editable)
    render_widget_label(r)
    render_widget(r, editable)
  end
  
  def render_widget_label(r)
    r.table_data do r.text(r.label_for(@name.dup) + ':') end
  end
  
  def render_widget(r, editable)
    r.text(@value)
  end
end

class MoTunes::TextInput < MoTunes::Widget
  def render_widget(r, editable)
    r.table_data do
      r.element_id(@name)
      if editable
        r.text_input(@value) do |new_value| @value = new_value end
      else
        r.open_tag('span')
        r.text(@value)
        r.close
      end
    end
  end
end

class MoTunes::Select < MoTunes::Widget
  def initialize(name, value=nil, select_list=[])
    @name = name
    @value = value
    @select_list = select_list
  end
  
  def render_widget(r, editable)
    r.table_data do 
      r.element_id(@name)
      if editable
        r.select(@select_list, @value) do 
          |selected_item| @value = selected_item 
        end
      else
        r.open_tag('span')
        r.text(@value)
        r.close
      end
    end  
  end
end

class MoTunes::Address 
  def initialize(name_prefix='')
    name_prefix << "_" if !name_prefix.empty?
    @values = [
      MoTunes::TextInput.new(name_prefix + 'first_name'),      
      MoTunes::TextInput.new(name_prefix + 'last_name'),
      MoTunes::TextInput.new(name_prefix + 'address_1'),
      MoTunes::TextInput.new(name_prefix + 'address_2'),
      MoTunes::TextInput.new(name_prefix + 'city'),
      MoTunes::Select.new(name_prefix + 'state', nil, STATES),
      MoTunes::TextInput.new(name_prefix + 'zip')
    ]
  end
  
  def render_on(r, editable)
    r.table do
      @values.each do |widget|
        r.table_row do 
          widget.render_on(r, editable)
        end
      end
    end
  end
  
  STATES = [
    'IDOHIA',
    'TX'
  ]

end
