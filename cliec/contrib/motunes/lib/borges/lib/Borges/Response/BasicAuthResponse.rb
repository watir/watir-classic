class Borges::BasicAuthResponse < Borges::Response

  def initialize(realm)
    @realm = realm

    super()

    @status = 401
    @headers.update({'WWW-Authenticate' => %^Basic realm="#{@realm}"^})

    @contents = "<h1>Authentication Failed</h1>"
  end

end

