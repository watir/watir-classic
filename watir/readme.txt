This is an early release of the watir web testing framework for Internet Explorer and Ruby.
This release is to evaluate how well the api would work, and to gain feedback on it.


How To Use:
-----------
This only works on Windows.
This has been developed and tested using Ruby 1.8.1-11 using Windows 2000 and XP.
If you are using XP service pack2, you may have problems with the unit tests. Check out the mail lists and the documentation for the workarounds
Install ruby from http://ruby-lang.org
Install the watir files, unit tests and sample html pages. 
run the unittests by going to the dir where you installed to, cd unittests, then run the tests.


Things Still to be Done:
------------------------
waitForIE may change to use the events from Internet Explorer. This will help detect page changes that are very quick ( from a local file system)
Pluggable error checker - I have some classes that continually check for errors, and report on them. These need to be incorporated.
Support for textarea
RDoc - I always need to add documentation to the classes and methods
Javascript pop ups
New browser windows

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

Coding Conventions:
-------------------
All require paths should be relative to the top of the
development hierarchy.