This is an early release of the watir web testing framework for Internet Explorer and Ruby.
This release is to evaluate how well the api would work, and to gain feedback on it.
Currently only button objects are supported.


How To Use:
-----------
This only works on Windows.
This has been developed and tested using Ruby 1.8.1-11 using Windows 2000 and XP
Install ruby from http://ruby-lang.org
Install the watir files, unit tests and sample html pages. 
run the unittests by going to the dir where you installed to, cd unittests, then run the tests.


Things Still to be Done:
------------------------
Logging - I think the best way for this is to have a logging object be passed into the watir constructor.
Getting elements by index - ie.button(:index , 2).click - this requires some changes to the getObject method of watir
waitForIE may change to use the events from Internet Explorer. This will help detect page changes that are very quick ( from a local file system)
Pluggable error checker - I have some classes that continually check for errors, and report on them. These need to be incorporated.
Support for: links, text , textarea, select box, radio, checkboxes.
RDoc - I need to add documentation to the classes and methods

Contacts:
---------
Paul Rogers (paul.rogers@shaw.ca)
Bret Pettichord ( bret@pettichord.com )

Acknowledgements:
-----------------
Many people have been involved in getting to this point. If Ive forgotten you, its not because your contribution was small, but because I forget things.
Chris Morris
Brian Marrick
Jonathan Kohl
Penny Tonita
Janet Gregory
Peter Chau




