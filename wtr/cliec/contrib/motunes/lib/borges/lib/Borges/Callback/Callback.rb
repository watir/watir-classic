class Borges::Callback

  def evaluate_with_store(obj, callback_store)
    raise NoMethodError.new("Subclass Responsibility")
  end

  def action_callback?
    false
  end

  def dispatch_callback?
    false
  end

  def value_callback?
    false
  end

end

