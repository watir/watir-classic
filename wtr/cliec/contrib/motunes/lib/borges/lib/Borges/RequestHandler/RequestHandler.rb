class Borges::RequestHandler

  THREAD_GROUP = ThreadGroup.new

  def handle_request(req)
    return handle_request_intern(req)
  end

  def handle_request_intern(aRequest)
    raise NotImplementedError.new("Subclass responsibility")
  end

end

