class Borges::WalkbackPage < Borges::ErrorPage

  def debug
    exception.defaultAction
  end

  def print_option_on_with_url(sym, res, url)
    res << %^<a href="#{url}?debug=#{sym}">#{sym}</a>^
  end

  def response_with_url(url)
    res = Borges::GenericResponse.new('text/html')
    res << '<small>'

    [:debug].each do |sym|
      print_option_on_with_url(sym, res, url)
    end

    res << '</small><br />'
    
    print_walkback_on(res)

    return res
  end

  def show
    session.redirect

    req = session.respond do |url|
      response_with_url(url)
    end

    self.send(req.fields['debug'].intern)
  end

end

