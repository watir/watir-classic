# Here's another example, using Google and a form wrapper class. 

require 'cl/iec'

VISIBLE = true
@iec = ClIEController.new(VISIBLE)
@iec.navigate 'http://www.google.com'
form = IEDomFormWrapper.new(@iec.form)
form.q = 'web testing ruby'
form.submit
@iec.wait
