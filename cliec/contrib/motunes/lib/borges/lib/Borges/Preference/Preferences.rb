class Borges::Preferences < Hash

  alias_method :get, :[]

  def [](pref)
    return super(pref).value
  end

  def []=(pref, val)
    cur_val = get(pref)

    unless cur_val.nil? then
      if val.kind_of? Borges::Preference then
        val = val.value
      end

      return cur_val.value = val
    end

    unless val.kind_of? Borges::Preference then
      val = Borges::Preference.new(val)
    end

    return super(pref, val)
  end

  def update(prefs)
    return super(prefs)
  end

end

