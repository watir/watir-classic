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

require 'motunes.test'

class TestCheckout < TestMoTunesBase
  def test_checkout
    home
    @iec.browse
    @iec.bill_evans
    @iec.montreux_ii
    @iec.add
    @iec.checkout
    @iec.options[:demo_wait] = 0.5
    @iec.bill_first_name = 'Chris'
    @iec.bill_last_name = 'Morris'
    @iec.bill_address_1 = '2021 Loon Lake Rd.'
    @iec.bill_city = 'Denton'
    @iec.bill_state = 'TX'
    @iec.bill_zip = '76210'
    
    @iec.ship_first_name = 'Carolyn'
    @iec.ship_last_name = 'Morris'
    @iec.ship_address_1 = '6842 Abbot Pl.'
    @iec.ship_city = 'Worthington'
    @iec.ship_state = 'IDOHIA'
    @iec.ship_zip = '43085'

    #@iec.ship_is_bill = true
    @iec.submit
    
    assert_equal('Chris', @iec.bill_first_name)
    assert_equal('Morris', @iec.bill_last_name)
    assert_equal('2021 Loon Lake Rd.', @iec.bill_address_1)
    assert_equal('Denton', @iec.bill_city)
    assert_equal('TX', @iec.bill_state)
    assert_equal('76210', @iec.bill_zip)
    
    assert_equal('Carolyn', @iec.ship_first_name)
    assert_equal('Morris', @iec.ship_last_name)
    assert_equal('6842 Abbot Pl.', @iec.ship_address_1)
    assert_equal('Worthington', @iec.ship_city)
    assert_equal('IDOHIA', @iec.ship_state)
    assert_equal('43085', @iec.ship_zip)
  end
end
