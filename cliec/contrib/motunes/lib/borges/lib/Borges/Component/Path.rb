class Borges::Path < Borges::Component

  def choose(anAssociation)
    newStack = Array.new.writeStream
    @stack.each do |ea|
      newStack.nextPut(ea)
      if ea == anAssociation then
        @stack = newStack.contents
        return self
      end
    end
  end

  def current_segment
    if @stack.empty? then
      nil
    else
      @stack.last.value
    end
  end

  def initialize
    @stack = []
    self.session.register_for_backtracking(self)
  end

  def push_segment_name(anObject, aString)
    @stack << [aString, anObject]
  end

  def render_content_on(r)
    return self if @stack.empty?

    r.divNamed_with('path', proc do
      @stack.allButLast.each do |assoc|
        r.anchorWithAction_text(proc do
          self.choose(assoc)
        end, assoc.key)

        r.text(' >> ')
      end

      r.bold(@stack.last.key)
    end)
  end

end

