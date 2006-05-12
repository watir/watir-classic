class Borges::RedirectResponse < Borges::Response

  def initialize(location)
    super()

    @status = 302
    @headers['Location'] = location

    @contens = %^<title>302 - Redirect</title><h1>302 - Redirect</h1><p>You are being redirected to <a href="#{location}">#{location}</a>^
  end

end

