class Borges::Task < Borges::Controller

  def render_with(context)
    key = context.callbacks.register_action_callback do
      answer(go)
    end

    srn = Borges::SimulatedRequestNotification.new
    srn.request = Borges::Request.new(context.action_url, {}, {key => ''}, {})
    raise srn
  end

end

