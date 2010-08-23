# This is a generic HTML Element that is used to 
# locate all elements that share an attribute. The
# most common example would be finding elements that 
# all share the same class.
module Watir
  class HTMLElement < Element
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
    
    def locate
      @o = @container.locate_tagged_element('*', @how, @what)
    end
  end
end