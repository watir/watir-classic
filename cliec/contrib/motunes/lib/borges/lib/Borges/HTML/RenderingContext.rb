class Borges::RenderingContext

  attr_accessor :action_url, :callbacks, :document

  def initialize(document, action_url, callbacks)
    @action_url = action_url
    @document = document
    @callbacks = callbacks
  end

end

