class Borges::Once < Borges::Filter

  def handle_request_in(req, session)
    if @seen_keys.include? req.action_key then
      session.page_expired
    else
      @seen_keys << req.action_key
    end
  end

  def initialize
    @seen_keys = []
  end

end

