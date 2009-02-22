module FireWatir
  class Pre < NonControlElement
    TAG = 'PRE'
  end

  class P < NonControlElement
    TAG = 'P'
  end

  class Div < NonControlElement
    TAG = 'DIV'
  end

  class Span < NonControlElement
    TAG = 'SPAN'
  end

  class Strong < NonControlElement
    TAG = 'STRONG'
  end

  class Label < NonControlElement
    TAG = 'LABEL'

    #
    # Description:
    #   Used to populate the properties in the to_s method.
    #
    #def label_string_creator
    #    n = []
    #    n <<   "for:".ljust(TO_S_SIZE) + self.for
    #    n <<   "inner text:".ljust(TO_S_SIZE) + self.text
    #    return n
    #end
    #private :label_string_creator

    #
    # Description:
    #   Creates string of properties of the object.
    #
    def to_s
      assert_exists
      super({"for" => "htmlFor","text" => "innerHTML"})
      #   r=r + label_string_creator
    end
  end

  class Ul < NonControlElement
    TAG = 'UL'
  end

  class Li < NonControlElement
    TAG = 'LI'
  end

  class Dl < NonControlElement
    TAG = 'DL'
  end

  class Dt < NonControlElement
    TAG = 'DT'
  end

  class Dd < NonControlElement
    TAG = 'DD'
  end

  class H1 < NonControlElement
    TAG = 'H1'
  end

  class H2 < NonControlElement
    TAG = 'H2'
  end

  class H3 < NonControlElement
    TAG = 'H3'
  end

  class H4 < NonControlElement
    TAG = 'H4'
  end

  class H5 < NonControlElement
    TAG = 'H5'
  end

  class H6 < NonControlElement
    TAG = 'H6'
  end

  class Map < NonControlElement
    TAG = 'MAP'
  end

  class Area < NonControlElement
    TAG = 'AREA'
  end

  class Body < NonControlElement
    TAG = 'TBODY'
  end
  
  class Em < NonControlElement
    TAG = 'EM'
  end

end # FireWatir
