class Borges::GenericResponse < Borges::Response

  def initialize(mime_type = 'text/plain', obj = '')
    super()

    @headers['Expires'] = 'Thu, 01 Jan 2095 12:00:00 GMT'
    self.content_type = mime_type

    #@contents = obj.asMIMEDocument.to_s
    @contents = obj.to_s
  end

end

