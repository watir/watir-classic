require 'webrick'
require 'Borges'

##
# Borges::WEBrickServlet is a Servlet for use with WEBrick.
#
# To use:
#
# require 'Borges/WEBrick'
# Borges::WEBrickServlet.start
#
# This will start a WEBrick server on port 7000 and install an INT handler.
# The server can be killed with a ^C or by sending SIGINT.

class Borges::WEBrickServlet < WEBrick::HTTPServlet::AbstractServlet

  attr_accessor :handler

  ##
  # Create a WEBrickServlet.
  #
  # The :Handler option can be used to replace the default Dispatcher,
  # Borges::Dispatcher.

  def initialize(server, options = {})
    super
    @handler = options[:Handler] || Borges::Dispatcher.default
  end

  ##
  # WEBrick HTTP GET handler

  def do_GET(req, res)
    request = Borges::Request.new(req.path, req.header, req.query, req.cookies)
    begin
      response = @handler.handle_request(request)
    rescue Exception => e
      puts "!!"
      puts e.backtrace.join("\n")
      puts "!!"

      raise e
    end

    res.status = response.status
    res.body = response.contents

    response.headers.each do |k,v|
      res[k] = v
    end
  end

  ##
  # WEBrick HTTP POST handler (same as GET)

  alias do_POST do_GET

  ##
  # Create a new unstarted WEBrick server that listens on port 7000,
  # and mounts the Borges::WEBrickServlet on /borges.
  
  def self.create(options)
    options[:BindAddress] ||= '0.0.0.0'
    options[:Port] ||= 7000

    server = WEBrick::HTTPServer.new(options)
    #server.listen('127.0.0.1', 7000)  # seems superfluous
    server.mount("/borges", self, options)

    return server
  end

  ##
  # Start a Borges::WEBrickServlet with a SIGINT handler

  def self.start(options = {})
    server = self.create(options)

    trap("INT") do server.shutdown end
    server.start
    
    return server
  end

end

if $0 == __FILE__ then
  Borges::WEBrickServlet.start
end

