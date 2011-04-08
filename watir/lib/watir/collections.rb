module Watir
  #--
  #   These classes are not for public consumption, so we switch off rdoc
    
  # presumes element_class or element_tag is defined
  # for subclasses of ElementCollections
  module CommonCollection #:nodoc:all
    def element_tag
      element_class::TAG
    end
    
    def length
      @container.document.getElementsByTagName(element_tag).length
    end
    alias_method :size, :length
  end
  
  # This class is used as part of the .show method of the iterators class
  # it would not normally be used by a user
  class AttributeLengthPairs #:nodoc:all
    
    # This class is used as part of the .show method of the iterators class
    # it would not normally be used by a user
    class AttributeLengthHolder
      attr_accessor :attribute
      attr_accessor :length
      
      def initialize(attrib, length)
        @attribute = attrib
        @length = length
      end
    end
    
    def initialize(attrib=nil, length=nil)
      @attr=[]
      add(attrib, length) if attrib
      @index_counter = 0
    end
    
    # BUG: Untested. (Null implementation passes all tests.)
    def add(attrib, length)
      @attr << AttributeLengthHolder.new(attrib, length)
    end
    
    def delete(attrib)
      item_to_delete = nil
      @attr.each_with_index do |e,i|
        item_to_delete = i if e.attribute == attrib
      end
      @attr.delete_at(item_to_delete) unless item_to_delete == nil
    end
    
    def next
      temp = @attr[@index_counter]
      @index_counter += 1
      return temp
    end
    
    def each
      0.upto(@attr.length-1) { |i | yield @attr[i]   }
    end
  end
  
  #    resume rdoc
  #++
  
  # this class accesses the buttons in the document as a collection
  # it would normally only be accessed by the Watir::Container#buttons method
  class Buttons < ElementCollections
    def element_class; Button; end
    # number of buttons
    #   browser.buttons.length
    def length
      get_length_of_input_objects(["button", "submit", "image"])
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("disabled", 9)
      @show_attributes.add("value", 20)
    end
  end
  
  # this class accesses the file fields in the document as a collection
  # normal access is via the Container#file_fields method
  class FileFields < ElementCollections
    def element_class; FileField; end
    # number of file_fields
    #   browser.file_fields.length
    def length
      get_length_of_input_objects(["file"])
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("disabled", 9)
      @show_attributes.add("value", 20)
    end
  end
  
  # this class accesses the check boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkboxes method
  class CheckBoxes < ElementCollections
    def element_class; CheckBox; end
    # number of checkboxes
    #   browser.checkboxes.length
    def length
      get_length_of_input_objects("checkbox")
    end
    
    private
    def iterator_object(i)
      @container.checkbox(:index, i + 1)
    end
  end
  
  # this class accesses the radio buttons in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#radios method
  class Radios < ElementCollections
    def element_class; Radio; end
    # number of radios
    #   browser.radios.length
    def length
      get_length_of_input_objects("radio")
    end
    
    private
    def iterator_object(i)
      @container.radio(:index, i + 1)
    end
  end
    
  # this class accesses the select boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_lists method
  class SelectLists < ElementCollections
    include CommonCollection
    def element_class; SelectList; end
    def element_tag; 'SELECT'; end
  end
  
  # this class accesses the links in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#links method
  class Links < ElementCollections
    include CommonCollection
    def element_class; Link; end
    def element_tag; 'A'; end
    
    private
    def set_show_items
      super
      @show_attributes.add("href", 60)
      @show_attributes.add("innerText", 60)
    end
  end
  
  class Lis  < ElementCollections
    include CommonCollection
    def element_class; Li; end
    
    private
    def set_show_items
      super
      @show_attributes.delete( "name")
      @show_attributes.add( "className" , 20)
    end
  end
  
  # this class accesses the maps in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#maps method
  class Maps < ElementCollections
    include CommonCollection
    def element_class; Map; end
    def element_tag; 'MAP'; end
  end


  # this class accesses the areas in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#areas method
  class Areas < ElementCollections
    include CommonCollection
    def element_class; Area; end
    def element_tag; 'AREA'; end
  end
  
  # this class collects the images in the container
  # An instance is returned by Watir::Container#images
  class Images < ElementCollections
    def element_class; Image; end
    # number of images
    #   browser.images.length
    def length
      all = @container.document.all
      imgs = []
      all.each{|n| imgs << n if n.nodeName == "IMG"}
      imgs.length
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("src", 60)
      @show_attributes.add("alt", 30)
    end
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_fields method
  class TextFields < ElementCollections
    def element_class; TextField; end
    # number of text_fields
    #   browser.text_fields.length
    def length
      # text areas are also included in the TextFields, but we need to get them seperately
      get_length_of_input_objects(["text", "password"]) +
      @container.document.getElementsByTagName("textarea").length
    end
  end
  
  # this class accesses the hidden fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#hiddens method
  class Hiddens < ElementCollections
    def element_class; Hidden; end
    # number of hidden elements
    #   browser.hiddens.length
    def length
      get_length_of_input_objects("hidden")
    end
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#tables method
  class Tables < ElementCollections
    include CommonCollection
    def element_class; Table; end
    def element_tag; 'TABLE'; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
    end
  end
  # this class accesses the table rows in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#rows method
  class TableRows < ElementCollections
    include CommonCollection
    def element_class; TableRow; end
    def element_tag; 'TR'; end
  end
  # this class accesses the table cells in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#cells method
  class TableCells < ElementCollections
    include CommonCollection
    def element_class; TableCell; end
    def element_tag; 'TD'; end
  end
  # this class accesses the labels in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#labels method
  class Labels < ElementCollections
    include CommonCollection
    def element_class; Label; end
    def element_tag; 'LABEL'; end
    
    private
    def set_show_items
      super
      @show_attributes.add("htmlFor", 20)
    end
  end
  
  # this class accesses the pre tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#pres method
  class Pres < ElementCollections
    include CommonCollection
    def element_class; Pre; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end
  
  # this class accesses the p tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#ps method
  class Ps < ElementCollections
    include CommonCollection
    def element_class; P; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
    
  end
  # this class accesses the spans in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#spans method
  class Spans < ElementCollections
    include CommonCollection
    def element_class; Span; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end
  
  # this class accesses the divs in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#divs method
  class Divs < ElementCollections
    include CommonCollection
    def element_class; Div; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end
  
  class Dls < ElementCollections
    include CommonCollection
    def element_class; Dl; end
    def element_tag; Dl::TAG; end
  end

  class Dts < ElementCollections
    include CommonCollection
    def element_class; Dt; end
    def element_tag; Dt::TAG; end
  end

  class Dds < ElementCollections
    include CommonCollection
    def element_class; Dd; end
    def element_tag; Dd::TAG; end
  end
  
  class Strongs < ElementCollections
    include CommonCollection
    def element_class; Strong; end
    def element_tag; Strong::TAG; end
  end
  
  class Ems < ElementCollections
    include CommonCollection
    def element_class; Em; end
    def element_tag; Em::TAG; end
  end

  class Frames < ElementCollections
    def element_class; Frame; end

    def length
      @container.document.getElementsByTagName("FRAME").length +
        @container.document.getElementsByTagName("IFRAME").length
    end
  end

  class Forms < ElementCollections
    def element_class; Form; end
    def element_tag; 'FORM'; end
    def length
      @container.document.getElementsByTagName("FORM").length
    end
  end
  
  class HTMLElements < ElementCollections
    include CommonCollection
    def element_class; HTMLElement; end
    def element_tag; '*'; end

    def initialize(container, how, what)
      @how = how
      @what = what
      if how == :index
        raise MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute #{@how}"
      end
      super(container)
    end
    
    def length
      count = 0
      each {|element| count += 1 }
      count
    end
    alias :size :length
  
    def each
      @container.locate_all_elements(@how, @what).each { |element| yield element }
    end
    
    def iterator_object(i)
      count = 0
      each {|e|  return e if count == i;count += 1;}
    end
    
  end
  
end
