=begin rdoc

This is Watir - Web Application Testing In Ruby    http://wtr.rubyforge.org

Install Ruby http://ruby-lang.org
   First you need to install Ruby using the one-click installer for Windows. We
   recommend Ruby 1.8.6.

   However, if you wish to use Watir's support for the IE showModalDialog then
   you must use Ruby 1.8.2-15 (or 1.8.2-14) and not a more recent version. This
   dialog is the one that is posted with the showModalDialog() JavaScript
   command and is supported with Watir's ie.modal_dialog command.

Install Watir
   Watir is packaged as a gem, a Ruby library that can be installed over the
   internet.

   Watir 1.5 was released in September 2007. To install it, type this at a
   command prompt:
      gem install watir

   Watir 1.4 was released in August 2005. If you are upgrading from it, see
   these notes: http://wiki.openqa.org/display/WTR/Development+Builds

How To Use:
   This only works on Windows.
   Requires Internet Explorer 5.5 or newer.
   Check out the mail lists and the documentation for the workarounds.

User Guide:    http://wiki.openqa.org/display/WTR/User+Guide

Unit Tests:
   Run the unittests in a cmd shell. Go to the dir where you installed it and then type 'ruby unittests/core_tests.rb'.
   See the user guide if you are having problems with security blocking.

Typical Usage
   # include the controller 
   require 'watir' 
   # create an instance of the controller 
   ie = Watir::IE.new  
   # go to the page you want to test 
   ie.goto('http://myserver/mypage') 
   # to enter text into a text field - assuming the field is named 'username' 
   ie.text_field(:name, 'username').set('Paul') 
   # if there was a text field that had an id of 'company_ID', you could set it to 'Ruby Co': 
   ie.text_field(:id ,'company_ID').set('Ruby Co') 
   # to click a button that has a caption of 'Cancel' 
   ie.button(:value, 'Cancel').click 

  Identifying something using two or more identifying characteristics
   # Html objects can also be identified via a combination of two of the above methods, 
   # for example to click a span with a class name of 'Label', and whose text is 'Add new', one could say
   ie.span(:class =>'Label', :text => 'Add new').click
   # Or to find one object within another (for example the first text_field within a div of class 
   # 'PasswordInput', where your password equals 'MyPassword'), one could say
   ie.div(:class, 'PasswordInput').text_field(:index, 1).set('MyPassword')
   
  The ways that are available to identify an html object depend upon the object type, but include
   :id           used for an object that has an ID attribute.*
   :name         used for an object that has a name attribute.*
   :value        value of text fields, captions of buttons. 
   :index        finds the nth object of the specified type - eg button(:index , 2) finds the second button. This is 1 based. <br>
   :class        used for an object that has a class attribute.
   :text         used for links and other objects that contain text.
   :xpath        finds the item using xpath query

   * :id and :name are the quickest of these to process, and so should be used when possible to speed up scripts.

 These 2 web sites provide info on Internet Explorer and on the DOM as implemented by Internet Explorer
 http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/webbrowser.asp
 http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/overview/overview.asp

 Command line options:

  -b  (background)   Run Internet Explorer invisible
  -f  (fast)         Run tests very fast
  
 Note that if you also use test/unit, you will need to require 'watir' first to avoid conflicts
 with its command line switches.

Javascript Pop Up Support
   Watir now optionally installs AutoIt - http://www.autoitscript.com/
   This is the prefered method for dealing wth pop ups, file requesters etc. Support for Winclickers will be removed.

Contacts:
   Bret Pettichord (bret@pettichord.com)
   Charley Baker (charley.baker@gmail.com)
   Paul Rogers (paul.rogers@shaw.ca)
   The mailing list: http://groups.google.com/group/watir-general

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
   Jared Luxenberg
   Alexey Verkhovsky
   Tuyet Cong-Ton-Nu
   Jeff Wood
   Angrez Singh
   Abhishek Goliya
   Yaxin Wang
   Michael Bolton
   Paul Carvalho
   Konstantin Sobolev
   David Schmidt 
   Dara Lillis
   Charley Baker
   Prema Arya
   Xavier Noria
   Jeff Fry
   Zeljko Filipin
   Paul Taylor - Bug fix 194
   Vincent Xu - Chinese input support
   Tomislav Car - Filefield fix (210)
   Michael Hwee & Aidy Lewis - Multiple attribute support for FireWatir (233)
   Alan Baird - Fix for visible? method (253)
   Jari Bakken - Regexp support for includes? and selected? methods for select lists (261)

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
