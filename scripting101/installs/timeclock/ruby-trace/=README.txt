This is the Ruby-Trace package. It's a way of adding tracing
statements to Ruby programs. 

The documentation is in the doc subdirectory, and also at 
<http://visibleworkings.com/ruby-trace/>
The doc/examples subdirectory contains examples.

To install:

1) Arrange for Ruby to look for files in this directory. For example,
   put this in your shell startup file:

     export RUBYLIB="$RUBYLIB:/usr/ruby/download/ruby-trace"

2) There are two files, ruby-trace and todo, in the bin subdirectory.
   Either put that directory in your search path or copy the files
   somewhere already in your search path.

3) Those two files are Ruby code. Their first line tells a shell where
   to find Ruby. It reads like this:

     #!/usr/bin/env ruby
   
   If that doesn't work on your system, change it to something that
   does, or invoke ruby explicitly ("ruby ruby-trace ..."). On my
   system, I have to change the line to read

     #!//e/progs/ruby/bin/ruby
   
That should do it. Comments, questions, and bug reports either to me,
marick@visibleworkings.com, or to the Ruby-trace mailing list, which
is ruby-trace@yahoogroups.com (join via
<http://groups.yahoo.com/group/ruby-trace>).

This is Ruby-trace $Name$.
