class Borges::Counter < Borges::Component

  def decrement
    @count -= 1
  end

  def increment
    @count += 1
  end

  def initialize
    @count = 0
    session.register_for_backtracking(self)
  end

  def render_content_on(r)
    r.heading(@count)
    r.anchor('++') do increment end
    r.space
    r.anchor('--') do decrement end
  end

  register_application('counter')

end

