# iec-assist.rb
require 'cl/iec'

$DEFAULT_URL = 'http://localhost:8080'

# ARGV need to be deleted to enable the Test::Unit functionatily that grabs
# the remaining ARGV as a filter on what tests to run
$HIDE_IE = ARGV.include?('-b'); ARGV.delete('-b')

def start_ie( url=$DEFAULT_URL, visible = ! $HIDE_IE )
  "Start the IE Controller at the specified URL."
  @iec = ClIEController.new({ :visible => visible })
  @iec.navigate(url)
  $iec = @iec
  return @iec
end

def form # block
  forms = $iec.document.forms
  forms.extend( Enumerable )
  form = forms.find{ |f| yield f }
  form ? IEDomFormWrapper.new( form ) : nil
end

def get_forms()
  "Return the Forms on the current page of IE as an array."
  page_forms = []
  for form in @iec.document.forms
    page_forms << IEDomFormWrapper.new(form)
  end
  return page_forms
end
alias forms get_forms

def show_forms()
  "Print the actions for each of the forms on the current page."
  page_forms = []
  for form in @iec.document.forms
    puts "action: " + form.action
  end
end
  
def get_form_by_action( action )
  "Return the first Form on the current page that has the specified Action."
  form { |f| f.action == action }
end

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
  
def show_elements(form = $iec)
  "Print the Name and Value of the Elements in the Form."
  for element in form.elements
    puts "name: " + element.name + " value: " + element.value
  end
end

def get_element_by_value(form, value)
  "Return the first Element of the Form with the specified Value"
  form.element {|e| e.value == value }
end

def button_click_by_name(form_action, button_name)
  "Click the button named button_name in the form with action form_action." 
#  form {|f| f.action == form_action }.element{|e| e.name == button_name}.click
  form {|f| f.action == form_action }.elements(button_name).click
  @iec.wait
end

def button_click_by_value(form_action, button_value)
  "Click the button with the value button_value in the form with action form_action." 
  form {|f| f.action == form_action }.element{|e| e.value == button_value }.click
  @iec.wait
end



def get_html
  "Return the full html of the current page."
  @iec.document.getElementsByTagName("HTML").item(0).outerHtml
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


### Timeclock Specific

def get_status_message
  "Return the status message. Examples are:
No job is recording time, or Job 'ruby article' is running."
  text = $iec.document.getElementsByTagName("P").item(3).innerHtml
  text[/^[^\.]*\./]
end







