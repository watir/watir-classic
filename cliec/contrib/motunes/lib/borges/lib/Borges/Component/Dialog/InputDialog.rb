class Borges::InputDialog < Borges::Component

  def default(aString)
    @value = aString
  end

  def label(arg = :noarg)
    move_method('key=', 'key') unless arg == :noarg

    @label = 'OK' if @label.nil?

    return @label
  end

  def label=(aString)
    @label = aString
  end

  def message(aString)
    @message = aString
  end

  def render_content_on(r)
    r.heading_level(@message, 3)
    r.form do
      r.defaultAction do self.answer(@value) end
      r.textInputWithValue_callback(@value, proc do |v| @value = v end)
      r.space
      r.submitButtonWithText(self.label)
    end
  end

end

