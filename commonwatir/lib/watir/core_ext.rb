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
end