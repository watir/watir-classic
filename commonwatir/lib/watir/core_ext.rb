class String

  #
  # "Watir::Span" => "Span"
  # 

  def demodulize
    gsub(/^.*::/, '')
  end

  #
  # "FooBar" => "foo_bar"
  # 

  def underscore
    gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
  end

  #
  # "Checkboxes" => "Checkbox"
  # "Bodies" => "Body"
  # "Buttons" => "Button"
  #
  def singularize
    case self.downcase
    when "checkboxes"
      self.chop.chop
    when "bodies"
      self.chop.chop.chop + "y"
    else
      self.chop
    end
  end
end
