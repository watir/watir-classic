##
# Borges' internal HTTP request representation

class Borges::Request

  attr_reader :action_key, :handler_key
  attr_reader :cookies, :fields, :headers, :path, :url
  attr_reader :username, :password

  ##
  # Parse and store Basic authentication, if any

  def parse_auth
    auths = headers['authorization']

    return if auths.nil?

    auth = auths.last # XXX doesn't allow for multiple auth headers

    if auth =~ /Basic/ then
      @username, @password = auth.split(' ').last.unpack('m')[0].split(':')
    end
  end

  ##
  # Parse and store pieces of the URL

  def parse_url
    if @url =~ /(.*)#{Borges::Registry::HANDLER_KEY_SEPARATOR}([^\/]+)(?:\/(.*))?/ then
      @path = $1
      @handler_key = $2.intern
      @action_key = $3.intern if !$3.nil?
    else
      @path = @url
    end
  end

  ##
  # Construct a Request from a +url+, the request +headers+, the
  # query/POST +fields+, and the +cookies+.
  #
  # NOTE: The URL is really the path portion of a URI, not including
  # the host.

  def initialize(url, headers, fields, cookies)
    @url = url
    @headers = headers
    @fields = fields
    @cookies = cookies

    parse_url
    parse_auth
  end

end

