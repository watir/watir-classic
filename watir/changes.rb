=begin rdoc

Changes in 1.5
    New Feature WTR-84  add the ability to parameterize the number of times an object flashes
    New Feature WTR-62  Add ability to access a Label by it's text
    New Feature WTR-53  Methods for visible/hidden
    New Feature WTR-3   Provide asynchronous click method
    Improvement WTR-141 check_for_http_error fix for IE7
    Improvement WTR-132 Performance Improvement - remove late binding for 1.5
    Improvement WTR-109 Support accessing IFrames by ID
    Improvement WTR-82  rdoc update and general fixes
    Improvement WTR-73  Request :class be provided as an alias for :class_name
    Improvement WTR-69  clearer error message if object passed to E#contains_text is not Regexp or String
    Improvement WTR-50  radio().checked? isn't there
    Bug         WTR-143 Rdoc should not include contrib code
    Bug         WTR-139 Element#ole_object often returns nil
    Bug         WTR-125 Updates to support IE7
    Bug         WTR-124 winClicker.rb undefined local variable
    Bug         WTR-123 ie.exists? doesn't work with IE7
    Bug         WTR-114 'element_by_xpath' breaks if page has &nbsp;
    Bug         WTR-112 missing include in watir/contrib/enabled_popup.rb
    Bug         WTR-111 Release 1.5.1.1100 breaks enabled_popup.rb
    Bug         WTR-108 file_field.set not working
    Bug         WTR-107 need a frame recursive wait
    Bug         WTR-105 bonus_zip rake task silently fails when there is no zip executable available
    Bug         WTR-102 frame.contains_text missing
    Bug         WTR-101 Broke send_keys.rb unit test after adding field to textfields1.html
    Bug         WTR-95  exception thrown when contains_text called for empty ie
    Bug         WTR-89  Retrieving elements using regular expressions causes errors and IE to crash
    Bug         WTR-86  The win32ole.so file packaged with Watir will not load with Ruby 1.8.4
    Bug         WTR-85  Rdoc is not created for "generated" methods
    Bug         WTR-80  Selecting element by specifying form object does not work
    Bug         WTR-77  ie.element(:id, 'foo') actually searches by Name
    Bug         WTR-72  Fix Google Example for non-English users
    Bug         WTR-68  remove output for FileField#set
    Bug         WTR-31  minimize/maximize don't work without prior browser navigation
    Bug         WTR-30  WinClicker problems when ruby/watir installed in program files
    Bug         WTR-24  Image.save method flaw
    Bug         WTR-17  Click_no_wait produces an error--'method_missing': busy (WIN32OLERuntimeError)--during execution.
    Bug         WTR-16  Error when window closes using IE.attach
    Bug         WTR-13  example/google_maps.rb needs to be updated
    Bug         WTR-6   click_no_wait only works with IE, not other container objects.
    See http://jira.openqa.org/browse/WTR for more details on the changes above.   

Changes in 1.4
   fix method name for accessing class name of P/Span/Div (change from style to class_name)
   fix for bug 2152 (frame index in show_frames off by 1)
   added alt as a property to image
   added file_fields
   fixed TextArea#to_s
   moved reset button to buttons class
   add IE#send_keys
   frames can now be referenced using regexps and ids
   added IE#minimize, IE#maximize, IE#restore
   onChange and onBlur events now triggered by TextField#set
   added default option to set for checkbox
   added colspan method to tablecell
   fix for bug reported by Scott P, wrong objects are sometimes found
   fixed Bug with radio/checkboxes doing multiple fireevents
   fix for table, id and reg exp
   wait for page load before returning from IE.attach
   update to select_list -- new interface still in progress
   added .show method to iterators
   fix for flashing objects in table cells
   added flash for forms
   flash returns nil instead of the curious '10'
   removed ScreenCapture module from IE class

Changes in 1.3.1
   Added P tag support
   Bug fix for images and links in frames using each
   Bug fixes for image#save

Changes in 1.3
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
   
=end
class Changes
end
