class Borges::BasicAuthentication < Borges::Filter

  attr_accessor :auth_block

  def initialize(&auth_block)
    @auth_block = auth_block
  end

  def handle_request_in(req, session)
    if @auth_block.call(req.username, req.password) then
      req 
    else
      session.return_response(Borges::BasicAuthResponse.new(session.base_path))
    end
  end

end

