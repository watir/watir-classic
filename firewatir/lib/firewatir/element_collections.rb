module FireWatir

  #
  # Description:
  #   Class for iterating over elements of common type like links, images, divs etc.
  #
  class ElementCollections
    include Enumerable
    include JsshSocket

    def self.inherited subclass
      class_name = Watir::Util.demodulize(subclass.to_s)
      method_name = Watir::Util.underscore(class_name)
      element_class_name = Watir::Util.singularize(class_name)

      FireWatir::Container.module_eval "def #{method_name}
      locate if respond_to?(:locate)
      return #{class_name}.new(self); end"

      subclass.class_eval "def element_class; #{element_class_name}; end"
    end

    @@current_level = 0

    def initialize(container)
      @container = container
      elements = locate_elements
      length = elements.length
      #puts "length is : #{length}"
      @element_objects = Array.new(length)
      for i in 0..length - 1 do
        @element_objects[i] = element_class.new(container, :jssh_name, elements[i])
      end
    end

    # default implementation. overridden by some subclasses.
    def locate_elements
      locate_tagged_elements(element_class::TAG)
    end


    # Return all the elements of given tag and type inside the container.
    #
    # Input:
    #   tag - tag name of the elements
    #   types - array of element type names. used in case where same
    #   element tag has different types like input has type image, button etc.
    #
    def locate_tagged_elements(tag, types = [])

      # generate array to hold results
      result_name = "arr_coll_#{tag}_#{@@current_level}"
      jssh_command = "var #{result_name}=new Array();"

      # generate array of elements matching the tag
      case @container
      when FireWatir::Firefox, FireWatir::Frame
        elements_tag = "elements_#{tag}"
        container_name = "#{@container.document_var}"
      else
        elements_tag = "elements_#{@@current_level}_#{tag}"
        container_name = @container.element_name
      end
      if types.include?("textarea") || types.include?("button")
        search_tag = '*'
      else
        search_tag = tag
      end

      # In HTML, getElementsByTagName is case insensitive. However, in XHTML, it needs to be lowercase.
      search_tag = search_tag.downcase

      jssh_command << "var #{elements_tag} = null; "
      jssh_command << "#{elements_tag} = #{container_name}.getElementsByTagName(\"#{search_tag}\");"


      # generate array containing results
      if types.empty?
        jssh_command << "#{result_name} = #{elements_tag};"
      else
        # generate types array
        jssh_command << "var types = new Array("
        types.each_with_index do |type, count|
          jssh_command << "," unless count == 0
          jssh_command << "\"#{type}\""
        end
        jssh_command << ");"

        # check the type of each element
        jssh_command << "
        for(var i=0; i<#{elements_tag}.length; i++)
        {
            var element = #{elements_tag} [i];
            var same_type = false;

            for (var j = 0; j < types.length; j++)
            {
                if (types[j] == element.type || types[j] == element.tagName)
                {
                    same_type = true;
                    break;
                }
            }

            if (same_type)
            {
                #{result_name}.push(element);
            }
        };"
      end
      jssh_command << "#{result_name}.length;"

      # Remove \n that are there in the string as a result of pressing enter while formatting.
      jssh_command.gsub!(/\n/, "")
      #puts jssh_command
      jssh_socket.send("#{jssh_command};\n", 0)
      length = read_socket().to_i;
      #puts "elements length is in locate_tagged_elements is : #{length}"

      elements = (0...length).collect {|i| "#{result_name}[#{i}]"}

      @@current_level = @@current_level + 1
      return elements
    end
    private :locate_tagged_elements

    #
    # Description:
    #   Gets the length of elements of same tag and type found on the page.
    #
    # Ouput:
    #   Count of elements found on the page.
    #
    def length
      return @element_objects.length
    end
    alias_method :size, :length

    #
    # Description:
    #   Iterate over the elements of same tag and type found on the page.
    #
    def each
      for i in 0..@element_objects.length - 1
        yield @element_objects[i]
      end
    end

    #
    # Description:
    #   Accesses nth element of same tag and type found on the page.
    #
    # Input:
    #   n - index of element (1 based)
    #
    def [](n)
      return @element_objects[n-1]
    end
    
    #
    # Returns the first element in the collection.
    # 
    
    def first
      @element_objects.first
    end
    
    #
    # Returns the last element in the collection.
    # 
    
    def last
      @element_objects.last
    end

    def to_s
      map { |e| e.to_s }.join("\n")
    end

    def inspect
      '#<%s:0x%x length=%s container=%s> elements=%s>' %
        [self.class, hash*2, length.inspect, @container.inspect, @element_objects.inspect]
    end

  end # ElementCollections

  #   Class for accessing all the button elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#buttons method
  class Buttons < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["button", "image", "submit", "reset"])
    end
  end

  #   Class for accessing all the File Field elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#file_fields method
  class FileFields < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["file"])
    end
  end

  #   Class for accessing all the CheckBox elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#checkboxes method
  class CheckBoxes < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["checkbox"])
    end
  end
  module Container
    alias checkboxes check_boxes
  end

  #   Class for accessing all the Radio button elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#radios method
  class Radios < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["radio"])
    end
  end

  #   Class for accessing all the select list elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#select_lists method
  class SelectLists < ElementCollections
    def locate_elements
      locate_tagged_elements("select", ["select-one", "select-multiple"])
    end
  end

  #   Class for accessing all the link elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#links method
  class Links < ElementCollections; end

  #   Class for accessing all the image elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#images method
  class Images < ElementCollections; end

  #   Class for accessing all the text field elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#text_fields method
  class TextFields < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["text", "textarea", "password"])
    end
  end

  #   Class for accessing all the hidden elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#hiddens method
  class Hiddens < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["hidden"])
    end
  end

  #   Class for accessing all the table elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#tables method
  class Tables < ElementCollections; end

  #   Class for accessing all the label elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#labels method
  class Labels < ElementCollections; end

  #   Class for accessing all the pre element in the document.
  #   It would normally only be accessed by the FireWatir::Container#pres method
  class Pres < ElementCollections; end

  #   Class for accessing all the paragraph elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#ps method
  class Ps < ElementCollections; end

  #   Class for accessing all the span elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#spans method
  class Spans < ElementCollections; end

  #   Class for accessing all the strong elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#strongs method
  class Strongs < ElementCollections; end

  #   Class for accessing all the div elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#divs method
  class Divs < ElementCollections; end

  #   Class for accessing all the ul elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#uls method
  class Uls < ElementCollections; end

  #   Class for accessing all the li elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#lis method
  class Lis < ElementCollections; end

  #   Class for accessing all the dl elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#dls method
  class Dls < ElementCollections; end

  #   Class for accessing all the dt elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#dts method
  class Dts < ElementCollections; end

  #   Class for accessing all the dd elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#dds method
  class Dds < ElementCollections; end

  #   Class for accessing all the dd elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#dds method
  class Ems < ElementCollections; end

  #   Class for accessing all the area elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#areas method
  class Areas < ElementCollections; end

  #   Class for accessing all the body elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#bodies method
  class Bodies < ElementCollections; end

  #   Class for accessing all the dd elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#maps method
  class Maps < ElementCollections; end

end # FireWatir
