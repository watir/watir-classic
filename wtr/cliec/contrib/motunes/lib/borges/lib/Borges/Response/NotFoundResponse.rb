class Borges::NotFoundResponse < Borges::Response

  def initialize(location)
    @location = location

    super()

    @status = 404

    @contents = %^<title>404 - Not Found</title><h1>404 - Not Found</h1><p>The location #{@location} does not exist on this server.^
  end

end

