module Watir
  class InputElementCollection < ElementCollection
    def each
      @container.locator_for(InputElementLocator, @how, element_class).each {|element| yield element}
    end    
  end

  class HTMLElementCollection < ElementCollection
    def each
      @container.locator_for(TaggedElementLocator, @how, Element).each { |element| yield element }
    end
  end

  %w[Button FileField Radio TextField TextArea Hidden SelectList CheckBox].each do |element|
    module_eval %Q[class #{element}Collection < InputElementCollection; end]
  end

  #class Inses < ElementCollection
    #def element_class; Ins; end
  #end

  #class TableSectionCollection < ElementCollection
    #def element_class; TableSection; end
  #end

  #%w[Form Frame Link Li Map Area Image Table TableRow TableCell TableHeader TableFooter TableBody
     #Label Pre P Span Dl Dt Dd Strong Em Del
     #Font H1 H2 H3 H4 H5 H6 Meta Ol Ul FieldSet Option].each do |element|
    #module_eval %Q[class #{element}Collection < ElementCollection; end]
  #end
  
end
