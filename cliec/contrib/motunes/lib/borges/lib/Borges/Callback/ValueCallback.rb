class Borges::ValueCallback < Borges::Callback

  def initialize(&block)
    @block = block
  end

  def evaluate_with_store(obj, callback_store)
    call(obj)
  end

  def value_callback?
    true
  end

  def call(obj)
    if @block.arity == 1 then
      @block.call(obj)
    else
      @block.call
    end
  end

end

