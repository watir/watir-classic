This is an early release of the watir web testing framework for Internet Explorer and Ruby.
This release is to evaluate how well the api would work, and to gain feedback on it.

To Install:
-----------
Execute install.rb.

How To Use:
-----------
This only works on Windows.
This has been developed and tested using Ruby 1.8.1-11, Ruby 1.8.1-12  using Windows 2000 and XP.
It will NOT work with Ruby 1.8.1-13. (This version of Ruby has a bad WIN32OLE library.)
Best is to use Ruby 1.8.2-14.
Check out the mail lists and the documentation for the workarounds.
Install ruby from http://ruby-lang.org
Install the watir files, unit tests and sample html pages. 
Run the unittests in a cmd shell. Go to the dir where you installed it and then type 'ruby unittests/all_tests.rb'.
See the user guide if you are having problems with security blocking.

Things Still to be Done:
------------------------
waitForIE may change to use the events from Internet Explorer. This will help detect page changes that are very quick ( from a local file system)
Pluggable error checker - I have some classes that continually check for errors, and report on them. These need to be incorporated.
RDoc - I always need to add documentation to the classes and methods
Javascript pop ups
New browser windows - experimental at the moment

Contacts:
---------
Paul Rogers (paul.rogers@shaw.ca)
Bret Pettichord (bret@pettichord.com)
The mailing list: http://rubyforge.org/mail/?group_id=104

Contributors:
-------------
Chris Morris
Brian Marick
Jonathan Kohl
Penny Tonita
Janet Gregory
Peter Chau
Danny Faught
Andy Tinkham
Atilla Ozgur
Lorenzo Jorquera
Elisabeth Hendrickson
Michael Kelly
Jacinda Scott (logo)
