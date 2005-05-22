=begin rdoc

This is Watir - Web Application Testing In Ruby    http://wtr.rubyforge.org


To Install:
   Execute install.rb. 

How To Use:
   This only works on Windows.
   Best is to use Ruby 1.8.2-14 or later.
   This has been developed and tested using Ruby 1.8.1-11, Ruby 1.8.1-12 using Windows 2000 and XP.
   It will NOT work with Ruby 1.8.1-13. (This version of Ruby has a bad WIN32OLE library.)
   Check out the mail lists and the documentation for the workarounds.
   Install ruby from http://ruby-lang.org
   Install the watir files, unit tests and sample html pages. 

Unit Tests:
   Run the unittests in a cmd shell. Go to the dir where you installed it and then type 'ruby unittests/core_tests.rb'.
   See the user guide if you are having problems with security blocking.

Changes in 1.3.1
   Added P tag support
   Bug fix for images and links in frames using each
   Bug fixes for image#save

Changes in 1.3
   These are the significant changes since 1.2

   added new row_values and column_value methods to tables
   added ability to save an image - ie.image(:index,1).save('c:\temp\mypic.gif')
   new method, html that applies to objects, not just a page - ie.button(:index,1).html => <INPUT id=b2 title="this is button1" onclick="javascript:document.location='pass.html';" type=button value="Click Me" name=b1>
   now throws a NavigationException on 404, 500 errors
   iterators now mixin Enumerable
   added support for labels
   added support for frames by index
   added screen_capture
   added hidden field support, and iterator method
   table cells, span and div now act as containers, so can do ie.div(:index,1).button(:index.2).click
   added index to print out from show_xx methods. Link shows img src if an image is used
   added onKeyUp and onKeyDown to text_fields#set
   installer now installs AutoIt to deal with javascript popups, file uploads etc
   the spinner is now off by default 
   bug fix in text_fields iterator where it wasnt iterating through password or text ares. Added test for password fields
   bug fix for flash for tables
   bug fixes for images and links in cells

Typical Usage
   # include the controller 
   require 'watir' 
   # create an instance of the controller 
   ie = Watir::IE.new  
   # go to the page you want to test 
   ie.goto("http://myserver/mypage") 
   # to enter text into a text field - assuming the field is name "username" 
   ie.text_field(:name, "username").set("Paul") 
   # if there was a text field that had an id of "company_ID", you could set it to Ruby Co: 
   ie.text_field(:id ,"company_ID").set("Ruby Co") 
   # to click a button that has a caption of 'Cancel' 
   ie.button(:value, "Cancel").click 
   
  The ways that are available to identify an html object depend upon the object type, but include
   :id           used for an object that has an ID attribute -- this is the best way!
   :name         used for an object that has a name attribute. 
   :value        value of text fields, captions of buttons 
   :index        finds the nth object of the specified type - eg button(:index , 2) finds the second button. This is 1 based. <br>
   :beforeText   finds the object immeditaley before the specified text. Doesnt work if the text is in a table cell
   :afterText    finds the object immeditaley after the specified text. Doesnt work if the text is in a table cell

  The objects that are currently supported include
   Button
   Radio
   CheckBox
   TextField (Including TextArea and Password)
   Hidden
   SelectList
   Label
   Span
   Div
   P
   Link
   Table 
   Image

 These 2 web sites provide info on Internet Explorer and on the DOM as implemented by Internet Explorer
 http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/webbrowser.asp
 http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/overview/overview.asp

 Command line options:

  -b  (background)   Run Internet Explorer invisible
  -f  (fast)         Run tests very fast
  -x  (spinner)      Add a spinner that displays when pages are waiting to be loaded.
  
 Note that if you also use test/unit, you will need to require 'watir' first to avoid conflicts
 with its command line switches.

Javascript Pop Up Support
   Watir now optionally installs AutoIt - http://www.autoitscript.com/
   This is the preffered method for dealing wth pop ups, file requesters etc. Support for Winclickers will be removed.

Contacts:
   Paul Rogers (paul.rogers@shaw.ca)
   Bret Pettichord (bret@pettichord.com)
   The mailing list: http://rubyforge.org/mail/?group_id=104

Contributors:
   Bret Pettichord
   Paul Rogers
   Jonathan Kohl
   Chris Morris
   Karlin Fox
   Lorenzo Jorquera
   Atilla Ozgur
   Justin McCarthy
   Chris McMahon
   Elisabeth Hendrickson
   Michael Kelly
   Peter Chau
   Danny Faught
   Andy Sipe
   John Lloyd-Jones
   Chris Hedges
   Park Heesob
   Shashank Date


Acknowledgements:
   Chris Morris
   Brian Marick
   Jonathan Kohl
   Penny Tonita
   Janet Gregory
   Andy Tinkham
   Jacinda Scott (logo creator)

   Thanks for your ideas and support!


=end
class ReadMe
end