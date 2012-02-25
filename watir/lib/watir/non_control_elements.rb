module Watir

  #class Ins < Element
    #Watir::Container.module_eval do
      #remove_method :inss

      #def inses(how={}, what=nil)
        #Inses.new(self, how, what)
      #end
    #end
  #end

  #class FieldSet < NonControlElement
    #Watir::Container.module_eval do
      #alias_method :fieldset, :field_set
      #alias_method :fieldsets, :field_sets
    #end
  #end

  #%w[Label Pre P Span Map Area Li Ul H1 H2 H3 H4 H5 H6
     #Dl Dt Dd Strong Em Del Ol Body Meta Font Frameset Div].each do |elem|
    #module_eval %Q{
      #class #{elem} < NonControlElement; end
    #}
  #end
  
end
