class Borges::ActionCallback < Borges::Callback

  def initialize(&block)
    @block = block
  end

  def evaluate_with_store(obj, callback_store)
    callback_store.action do call end
  end

  def action_callback?
    true
  end

  def call
    @block.call
  end

end

