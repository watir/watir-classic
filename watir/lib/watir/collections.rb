module Watir
  class InputElementCollections < ElementCollections
    def each
      @container.locate_input_element(@how, @what, element_class::INPUT_TYPES, element_class).each {|element| yield element}
    end    
  end
  # this class accesses the buttons in the document as a collection
  # it would normally only be accessed by the Watir::Container#buttons method
  class Buttons < InputElementCollections
  end
  
  # this class accesses the file fields in the document as a collection
  # normal access is via the Container#file_fields method
  class FileFields < InputElementCollections
  end
  
  # this class accesses the check boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkboxes method
  class CheckBoxes < InputElementCollections
    def element_class; CheckBox; end
  end
  
  # this class accesses the radio buttons in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#radios method
  class Radios < InputElementCollections
  end
    
  # this class accesses the select boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_lists method
  class SelectLists < InputElementCollections
    def element_tag; 'SELECT'; end
  end
  
  # this class accesses the links in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#links method
  class Links < ElementCollections
  end
  
  class Lis  < ElementCollections
  end
  
  # this class accesses the maps in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#maps method
  class Maps < ElementCollections
  end


  # this class accesses the areas in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#areas method
  class Areas < ElementCollections
  end
  
  # this class collects the images in the container
  # An instance is returned by Watir::Container#images
  class Images < ElementCollections
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_fields method
  class TextFields < InputElementCollections
  end
  
  # this class accesses the hidden fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#hiddens method
  class Hiddens < InputElementCollections
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#tables method
  class Tables < ElementCollections
  end
  # this class accesses the table rows in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#rows method
  class TableRows < ElementCollections
  end
  # this class accesses the table cells in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#cells method
  class TableCells < ElementCollections
  end
  # this class accesses the labels in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#labels method
  class Labels < ElementCollections
  end
  
  # this class accesses the pre tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#pres method
  class Pres < ElementCollections
  end
  
  # this class accesses the p tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#ps method
  class Ps < ElementCollections
  end
  # this class accesses the spans in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#spans method
  class Spans < ElementCollections
  end
  
  # this class accesses the divs in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#divs method
  class Divs < ElementCollections
  end
  
  class Dls < ElementCollections
  end

  class Dts < ElementCollections
  end

  class Dds < ElementCollections
  end
  
  class Strongs < ElementCollections
  end
  
  class Ems < ElementCollections
  end

  class Frames < ElementCollections
    def each
      @container.locate_frame_element(@how, @what).each {|element| yield element}
    end
  end

  class Forms < ElementCollections
    def each
      @container.locate_form_element(@how, @what).each {|element| yield element}
    end    
  end
  
  class HTMLElements < ElementCollections
    def each
      @container.locate_all_elements(@how, @what).each { |element| yield element }
    end
  end
  
end
