class Borges::DocumentHandler < Borges::RequestHandler

  attr_accessor :response
  attr_reader :document

  def initialize(obj, mime_type)
    @document = obj 
    @response = Borges::GenericResponse.new(mime_type, obj)
  end

  def handle_request_intern(req)
    return @response
  end

  def eql?(other)
    return other.document == self.document &&
           other.response.content_type == self.response.content_type
  end

  def hash
    return document.hash ^ response.content_type.hash
  end

  def active?
    return true
  end

end

