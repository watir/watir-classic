class Borges::StringPreference < Borges::Preference

  def render_on(r)
    r.attributes['size'] = [value.length, 10].max
    r.text_input_on(:value, self)
  end

end

