module Watir
  class Ul < NonControlElement
    TAG = 'UL'
  end
  module Container
    def ul(how, what)
      return Ul.new(self, how, what)
    end
  end
  
  class H1 < NonControlElement
    TAG = 'H1'
  end
  module Container
    def h1(how, what)
      return H1.new(self, how, what)
    end
  end
  
  class H2 < NonControlElement
    TAG = 'H2'
  end
  module Container
    def h2(how, what)
      return H2.new(self, how, what)
    end
  end

  class H3 < NonControlElement
    TAG = 'H3'
  end
  module Container
    def h3(how, what)
      return H3.new(self, how, what)
    end
  end

  class H4 < NonControlElement
    TAG = 'H4'
  end
  module Container
    def h4(how, what)
      return H4.new(self, how, what)
    end
  end

  class H5 < NonControlElement
    TAG = 'H5'
  end
  module Container
    def h5(how, what)
      return H5.new(self, how, what)
    end
  end
  class H6 < NonControlElement
    TAG = 'H6'
  end

  module Container
    def h6(how, what)
      return H6.new(self, how, what)
    end
  end

end