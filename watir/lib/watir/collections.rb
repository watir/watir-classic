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

  %w[Buttons FileFields Radios TextFields Hiddens].each do |collection|
    module_eval %Q{
      class #{collection} < InputElementCollections; end
    }
  end
  
  %w[Links Lis Maps Areas Images Tables TableRows TableCells
     Labels Pres Ps Spans Divs Dls Dts Dds Strongs Ems].each do |collection|
    module_eval %Q{
      class #{collection} < ElementCollections; end
    }
  end
  
end
