class Borges::DispatchCallback < Borges::Callback

  def evaluate_with_store(obj, callback_store)
    callback_store.evaluate_callback_with(obj, nil)
  end

  def dispatch_callback?
    true
  end

end

