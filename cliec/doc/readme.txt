===How-To

From a response on the Ruby mailing list. http://samie.sf.net, the Perl
equivalent of IEC, apparently works as follows:

  my $URL = "http://www.amazon.com";
  Navigate($URL);
  WaitForBusy();
  $IEDocument = GetDocument();
  $seconds = WaitForDocumentComplete();
  print "Amazon took $seconds seconds to load\n";
  SetListBoxItem("url","index=baby");
  SetEditBox("field-keywords","rattlesnake");
  ClickFormImage("Go");
  $seconds = WaitForDocumentComplete();
  print "Diaper page took $seconds seconds to load\n";

IEC would do the following:

  require 'cl/iec'

  VISIBLE = true
  iec = ClIEController.new(VISIBLE)
  iec.navigate('http://www.amazon.com')
  form = IEDomFormWrapper.new(iec.form)
  form.url = 'Baby'
  form.invoke('field-keywords').value = 'rattlesnake'
  form.submit
  iec.wait

Comments:
- the navigate method automatically calls the wait method, form.submit does
not.

- IEDomFormWrapper basically has a method_missing routine which handles a
bunch of dirty work. In prepping this, I found I usually have add a 'def
form...' method to my test scripts which will automatically take care of
creating the wrapper -- that helper function needs to be moved into the iec
lib.

- The built-in drop down wrapper allows you to set the drop down based on
the display value, not the internal value ('index=baby').

- Because Amazon put a hyphen in their edit box input name, the slick
method_missing approach in the form wrapper is thrwarted. Normally, you can
do:

iec.form.field-keywords = 'rattlesnake'

... but the hyphen is parsed as a method call so only the term 'field' is
caught by method missing -- so the lib tries to find a form field called
'field' and it fails to do so. invoke is a WIN32OLE method that allows you
to force a call through to the WIN32OLE instance. Because we're also not
getting to use the built in text box wrapper, we have to also reference the
.value property.

- The iec.form call takes an index argument that defaults to 0, but you can
set it to reference other forms on a multiple form page.

See the examples folder for more stuff.