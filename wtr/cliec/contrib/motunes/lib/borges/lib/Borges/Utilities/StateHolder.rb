class Borges::StateHolder

  attr_accessor :contents

  class << self
    alias orig_new new

    def new(*args)
      inst = orig_new(*args)

      Borges::Session.current_session.register_for_backtracking(inst)
      return inst
    end
  end

  def initialize(contents)
    @contents = contents
  end

end

