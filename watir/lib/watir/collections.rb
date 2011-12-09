module Watir
  class InputElementCollections < ElementCollections
    def each
      @container.input_element_locator(@how, @what, element_class::INPUT_TYPES, element_class).each {|element| yield element}
    end    
  end

  class Frames < ElementCollections
    def each
      @container.locator_for(FrameLocator, @how, @what).each {|element| yield element}
    end
  end

  class Forms < ElementCollections
    def each
      @container.locator_for(FormLocator, @how, @what).each {|element| yield element}
    end    
  end
  
  class HTMLElements < ElementCollections
    def each
      @container.locator_for(ElementLocator, @how, @what).each { |element| yield element }
    end
  end

  # this class accesses the check boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkboxes method
  class CheckBoxes < InputElementCollections
    def element_class; CheckBox; end
  end
    
  # this class accesses the select boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_lists method
  class SelectLists < InputElementCollections
    def element_tag; 'SELECT'; end
  end  

  %w[Button FileField Radio TextField Hidden].each do |element|
    module_eval %Q{
      class #{element}s < InputElementCollections; end
    }
  end

  class Inses < ElementCollections
    def element_class; Ins; end
  end
  
  %w[Link Li Map Area Image Table TableRow TableCell
     Label Pre P Span Div Dl Dt Dd Strong Em Del
     Font H1 H2 H3 H4 H5 H6 Meta Ol Ul FieldSet].each do |element|
    module_eval %Q{
      class #{element}s < ElementCollections; end
    }
  end
  
end
