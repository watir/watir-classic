=begin rdoc
== Version 1.5.3
Bug fixes and minor cleanup.

* Fix text areas bugs.
* Fix warning messages caused by redefined constants.
* Break out watir.rb into multiple files.
* Fix [WTR-90] error when running tests when installing gem.
  http://jira.openqa.org/browse/WTR-90
* Fix tests.
* Update documentation.

Major Changes in 1.5.1
    Support for IE's Modal Dialogs. 
      showModalDialog() 
    Any method can be used to specify an element (:text, :class, etc.). 
      ie.button(:class,'Button Menu').click
      ie.div(:text, 'Type').text_field(:class, 'TextInput-input').set('my value')
      ie.button(:text, 'Save').click 
    One can now use multiple attributes to specify an element.
      ie.span(:class =>'Label', :text => 'Add new').click
      
Other Changes in 1.5.1
    * Migrated IE.new_process from watir/contrib and improved its reliability. We now recommend IE.new_process over IE.new as a way to avoid numerous errors detailed in http://jira.openqa.org/browse/WTR-150.
    * Added IE.start_process. This works like IE.start, but uses the new_process mechanism to start IE.
    * Added IE.new_window and IE.start_window. This are synonyms for IE.new and IE.start.
    * Added dependency on the win32-process gem.
    * Added IE.each, which iterates through the various IE windows currently open.
    * Updated WindowHelper and watir/dialog to work with IE7
    * The wait method was completely rewritten. This should fix various errors seen in 1.5.1.1165 and 1.5.1.1158.
    * Removed the "spinner".
    * Fixed bug in Element#parent and updated unit test.
    * HTML value attributes are checked as strings before converting, updated unit tests.
    * Watir::wait_until clean up.
    * Fix for winclicker when installed in directory with spaces.
    * Rdoc changes and updates.
    * A workaround for frame access errors in the wait command, swallowing access denied errors and rethrowing if other WIN32OLERuntimeErrors show up.
    * Add support for "li" tag.
    * Fix for bug in element_by_xpath. http://www.mail-archive.com/wtr-general@rubyforge.org/msg06742.html
    * "Wait" method now is called recursively into nested frames. http://jira.openqa.org/browse/WTR-107
    * Rdocs now only include the core Watir library (not contrib).
    * Improve error reporting when IE#modal_dialog isn't found.
    * Add method "ModalDialog#exists?"
    * Add Watir::Win32.window_exists? method.
    * Fix for winclicker setComboBoxTest and setTextBoxText http://jira.openqa.org/browse/WTR-124
    * Improved Support for IE7
        o Fix for IE7 on ie.exists? http://jira.openqa.org/browse/WTR-123
        o Fix for IE7 with winclicker.
        o Fix for check_for_http_error in IE7. http://jira.openqa.org/browse/WTR-141
    *  Fix for IE7 on ie.exists? http://jira.openqa.org/browse/WTR-123
    * Rubyw is now used in winclicker to bypass command line windows.
    * Autoit is registered before being used.
    * Watir now checks for the right version of Ruby before loading our customized Win32ole library.
    * ie.file_field has been fixed and unit test updated.
    * rdoc generation has been fixed.
    * page checker has been moved from the default behavior into contrib/page_checker.rb
    * Fix for intermittent crashes occuring when using Watir with Ruby version > 1.8.2.
    * Fix for http://jira.openqa.org/browse/WTR-86
        This fix prevents the Watir-modified win32ole.so library (compiled against 1.8.2) from being used.
    * Added Element#parent
    * Add new methods Element#after? and Element#before?
    * Added support for relative specifiers. E.g.:
        link = $ie.link(:class => 'addtocart', :after? => @headline)
    * Removed NAVIGATION_CHECKER from Watir.rb, added to contrib. This fixes rdoc generation and stops the frame access exception being thrown in the default installation.
    * Open-code calls to def_creator, for easier debugging and rdoc generation of factory methods.
    * Winclicker fix for too many callbacks defined error.
    * Patch for rspec API changes
    * You can now reference an iframe using IE#frame(:id, 'whatever'). Jira 109
    * Added 'map' and 'area' element support.
    * Moved Watir::Assertions into new file watir/assertions.rb so they can be used outside test cases.
    * Fix and unit test for Jira 114, related to tag in HTML source.
    * Added SelectList#include? and SelectList#selected?
    * Added Element#visible?
    * Fixes all reported bugs with contains_text.
    * New Watir::TestCase#verify method (and verify_equal and verify_match).
    * The click_no_wait method now works in frames.
    * Released new IE.new_process method to 'watir/contrib/ie-new-process'. This starts up a new IE process for each IE window, which is really how it should be done. To close these use IE#kill. Any one getting intermittent RPC errors when opening windows may want to use this instead.
    * Several examples have been updated.
    * Moved enabled_popup to a new contrib directory.
    * Added several tests. 

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
