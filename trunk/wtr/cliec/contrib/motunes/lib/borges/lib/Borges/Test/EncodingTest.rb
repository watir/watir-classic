class EncodingTest < Borges::Component

  def render_content_on(r)
    r.code do 
      r.text('Start')
      r.break

      (32..255).each_with_index do |c, i|
        r.encode_text(c.chr)
        r.break if i % 16 == 0
      end

      r.text('End')
      r.break
    end

    r.text('Characters Encoded: ')
    r.break

    'Hello World'.each_byte do |c|
      r.encode_char(c)
    end

    r.break
  end

end

