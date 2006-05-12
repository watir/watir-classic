##
# The Dispatcher dispatches incoming requests to the correct
# handler (entry point) and registers server entry points.

class Borges::Dispatcher < Borges::RequestHandler

  @@default = nil

  ##
  # Retrieve the default Dispatcher, instantiating if it does not
  # yet exist.

  def self.default
    @@default = self.new if @@default.nil?

    return @@default
  end

  ##
  # Create a new Dispatcher with the given url_prefix with "/borges"
  # as the default.

  def initialize(url_prefix = "/borges")
    @url_prefix = url_prefix
    @entry_points = {}
  end

  ##
  # Retrieve a sorted copy of the Dispatcher's entry points.

  def entry_points
    return @entry_points.sort_by do |a| a.at(0) end
  end

  ##
  # Pass the request off to the handler for the request.

  def handle_request_intern(req)
    return handler_for_request(req).handle_request(req)
  end

  ##
  # Retrieve the handler for the request.  If no entry point matches,
  # return the NotFoundHandler.

  def handler_for_request(req)
    req.path =~ /^#{@url_prefix}\/([^\/]+)/

    return @entry_points[$1] || Borges::NotFoundHandler.new
  end

  ##
  # Register a new entry point at +path+.  The handler be invoked on
  # requests to "#{@url_prefix}/#{path}".

  def register(entry_point, path)
    @entry_points[path] = entry_point
    entry_point.base_path = "#{@url_prefix}/#{path}"
  end

  ##
  # Unregister an entry point and return it.

  def remove(entry_point)
    entry_point = entry_point.name if entry_point.kind_of? Borges::Application
    val = @entry_points.delete(entry_point)
  end

end

