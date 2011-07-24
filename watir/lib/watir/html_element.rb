# This is a generic HTML Element that is used to 
# locate all elements that share an attribute. The
# most common example would be finding elements that 
# all share the same class.
module Watir
  class HTMLElement < Element
    TAG = "*"

    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      if how == :index
        raise MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute #{@how}"
      end
      super nil
    end
    
    Watir::Container.module_eval do
      def element(how={}, what=nil)
        HTMLElement.new(self, how, what)  
      end
      
      def elements(how={}, what=nil)
        HTMLElements.new(self, how, what)  
      end
    end
  end
end
