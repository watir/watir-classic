class Borges::Response

  DEFAULT_HEADERS = { 'Content-Type' => 'text/html' }.freeze

  attr_accessor :contents, :status
  attr_reader :cookies, :headers

  def initialize
    @status = 200
    @headers = DEFAULT_HEADERS.dup
    @cookies = {}

    @contents = ""
  end

  def content_type
    @headers['Content-Type']
  end

  def content_type=(mime_type)
    @headers['Content-Type'] = mime_type
  end

  def <<(str)
    @contents << str
  end

end

