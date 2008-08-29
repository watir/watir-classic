# visible.rb
# Original Author: David Schmidt

# See http://wiki.openqa.org/pages/viewpage.action?pageId=1119
# for description and sample code.

# Here is an example of adding a new #visible? method to the Watir::Element 
# class which returns true or false to indicate whether the cell is visible. 
# The question of visibility isn't as easy as it seems, because there are 
# multiple styles to indicate visibility ("display: none" or 
# "visibility: hidden"). In addition, an element is hidden if any PARENT 
# element is hidden, even if that element would otherwise be visible.

# This method first checks the current element and then each parent element 
# for visibility until it reaches the top of the DOM element tree. Note that 
# this method is quite slow compared to other methods because it must recurse 
# all the way to the top of the DOM to guarantee that an element is truly 
# visible.

class Watir::Element

  # If any parent element isn't visible then we cannot write to the
  # element. The only realiable way to determine this is to iterate
  # up the DOM element tree checking every element to make sure it's
  # visible.
  def visible?
    # Now iterate up the DOM element tree and return false if any
    # parent element isn't visible or is disabled.
    object = document
    while object
      begin
        if object.style.invoke('visibility') =~ /^hidden$/i
          return false
        end
        if object.style.invoke('display') =~ /^none$/i
          return false
        end
        if object.invoke('isDisabled')
          return false
        end
      rescue WIN32OLERuntimeError
      end
      object = object.parentElement
    end
    true
  end
end