=============================
MoTunes IEC Demonstration App
=============================

LICENSE
-------

MoTunes source BSD License - Copyright Chris Morris 2004
see doc/license.txt

Borges is covered on its own terms. See http://segment7.net/ruby-code/borges/
(According to its RAA entry**, it has a BSD license as well, but no license
can be found in its distribution).

** http://raa.ruby-lang.org/list.rhtml?name=borges


INSTALLATION
------------

The MoTunes app is a modified and enhanced version of the sushiNet sample 
application included with Borges, which itself is a port of the sushiNet sample 
application included with Seaside [http://beta4.com/seaside2/].

The version of Borges distributed with MoTunes is 1.0.0-alpha3, stripped down 
(no docs, for one thing) with a few patches applied. It depends on WEBrick. If 
you're using Ruby 1.8, WEBrick is included in the Ruby distribution and you 
should only need to run lib/borges/setup.rb (read the README in the same dir for 
specifics, or try the do_setup.bat in the same dir). If you're using 1.6, 
WEBrick will need to be installed separately prior to installing Borges.

Since this is an IEC demonstration app, you'll of course need IEC installed. 
There's a good chance this demonstration app came as a part of the IEC 
distribution, but in case it didn't, get the latest from RubyForge 
[http://rubyforge.org/projects/wtr/].


USAGE
-----

After installing everything, you need to start the MoTunes WEBrick/Borges server 
with the src/run.motunes.rb. After that, you should be able to open up 
http://localhost:7000/borges/store to see the MoTunes front end (or use the 
src/motunes shortcut).

From here, you can experiment with the different Ruby files in the src folder. 
Here's a current rundown of what's in there, though this readme may be out of 
date. Just know from here on out you can do what you want with the sample 
application. There is no persistence of data in the web app, it's currently all 
stored in memory in Borges sessions (this can be a bit of a memory hog ... so if 
that's a concern, be careful), which is handy for experimenting with IEC as you 
can always start fresh.

  motunes.navigator.rb

    This is a base module that has a few helper methods that are mixed-in the 
    base TestCase class in motunes.test.rb, but can also be used outside of 
    Test::Unit by motunes.exploratory.rb.

  motunes.test.rb

    A base Test::Unit::TestCase class that mixes in some basic navigation and 
    fixture code from the navigator.rb file. The other test files descend from 
    here.

  motunes.exploratory.rb

    A file that can be run by itself or, preferably, inside irb to get IEC and 
    MoTunes up and running for further manual interaction. 

  motunes.test.*.rb

    Some specific test cases that demonstrate how to use IEC against the 
    application.