class Borges::NotFoundHandler < Borges::RequestHandler

  def handle_request_intern(req)
    return Borges::NotFoundResponse.new(req.path)
  end

end

