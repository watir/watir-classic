class Borges::Transaction < Borges::Filter

  def close
    @active = false
  end

  def handle_request_in(req, session)
    if @active then
      req
    else
      session.page_expired
    end
  end

  def initialize
    @active = true
  end

end

