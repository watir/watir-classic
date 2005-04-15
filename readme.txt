=begin rdoc

This is Watir - Web Application Testing In Ruby    http://wtr.rubyforge.org


To Install:
   Execute install.rb. 

How To Use:
   This only works on Windows.
   This has been developed and tested using Ruby 1.8.1-11, Ruby 1.8.1-12  using Windows 2000 and XP.
   It will NOT work with Ruby 1.8.1-13. (This version of Ruby has a bad WIN32OLE library.)
   Best is to use Ruby 1.8.2-14.
   Check out the mail lists and the documentation for the workarounds.
   Install ruby from http://ruby-lang.org
   Install the watir files, unit tests and sample html pages. 
   Run the unittests in a cmd shell. Go to the dir where you installed it and then type 'ruby unittests/all_tests.rb'.
   See the user guide if you are having problems with security blocking.


Typical Usage
    # include the controller 
   require 'watir' 
   include Watir
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


 command line options:

  -b  (background)   Run Internet Explorer minimised
  -s  (Spinner off)  Use this when you dont want the spinner displyed. Most usful when using an ide like eclipse or scite



Things Still to be Done:
   waitForIE may change to use the events from Internet Explorer. This will help detect page changes that are very quick ( from a local file system)
   RDoc - I always need to add documentation to the classes and methods
   Javascript pop ups
   New browser windows - experimental at the moment

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