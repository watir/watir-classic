class Borges::NavigationBar < Borges::Component

  attr_accessor :actions_selector, :owner

  def actions
    return target.send(@actions_selector)
  end

  def initialize(owner)
    @actions_selector = :actions
    @owner = owner
  end

  def render_content_on(r)
    actions.each do |symbol|
      r.anchor_on(symbol, target)
      r.break
    end
  end

  def target
    return @owner.active_controller
  end

end

