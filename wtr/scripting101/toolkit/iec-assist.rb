# iec-assist.rb
require 'cl/iec'
require 'toolkit/config'

# ARGV need to be deleted to enable the Test::Unit functionatily that grabs
# the remaining ARGV as a filter on what tests to run
$HIDE_IE = ARGV.include?('-b'); ARGV.delete('-b')

def start_ie( url=$DEFAULT_URL, visible = ! $HIDE_IE )
  "Start the IE Controller at the specified URL."
  $iec = ClIEController.new({ :visible => visible })
  $iec.navigate(url)
  return $iec
end

def wait() 
  $iec.wait
end

def form # block
  forms = $iec.document.forms
  forms.extend( Enumerable )
  form = forms.find{ |f| yield f }
  form ? IEDomFormWrapper.new( form ) : nil
end

def forms()
  "Return the Forms on the current page of IE as an array."
  page_forms = []
  for form in $iec.document.forms
    page_forms << IEDomFormWrapper.new(form)
  end
  return page_forms
end

def show_forms()
  "Print the actions for each of the forms on the current page."
  page_forms = []
  for form in $iec.document.forms
    puts "action: " + form.action
  end
end
alias show_form_actions show_forms
  
class CLabs::IEC::IEDomFormWrapper
  def element
    elements = self.elements
    elements.extend( Enumerable )
    elements.find{ |e| yield e }
  end
end

=begin
class CLabs::IEC::ClIEController
  def elements
    all = $iec.ie.document.all
    all.extend( Enumerable )
    all.select{ |a| a.tagName == 'INPUT' }
  end
end

def elements
  $iec.elements
end
=end
  
def show_elements(form)
  "Print the Name and Value of the Elements in the Form."
  for element in form.elements
    puts "name: " + element.name + " value: " + element.value
  end
end

###

def get_html
  "Return the full html of the current page."
  $iec.document.getElementsByTagName("HTML").item(0).outerHtml
end

def show_ole_methods(ole_object)
  "Print the ole/com methods for the specified object."
  for method in ole_object.ole_methods
    puts method.name
  end
end

class NilClass
  def strip
    nil
  end
end









