class Borges::NumberPreference < Borges::Preference

  def render_on(r)
    r.attributes['size'] = [value.to_s.length, 10].max

    r.text_input(value.to_s) do |v|
      @value = v.to_i
    end
  end

end

