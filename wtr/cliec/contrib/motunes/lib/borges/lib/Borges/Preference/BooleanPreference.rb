class Borges::BooleanPreference < Borges::Preference

  def render_on(r)
    r.boolean_menu_on(:value, self)
  end

end

