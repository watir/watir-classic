Each of the examples has instructions at the beginning of the file.

WARNING: Whenever the test suite is run, these examples are copied
into that directory and checked. So if you change them, the
Examples.rb tests will likely break.

print-example.rb
  How the ruby-trace program is used for simple printing
  of trace messages to standard output.

drain-example.rb
  How the ring buffer can be drained into a logfile upon error.

topic-example.rb
  Creating new topics.

topic-access-example.rb
  Different ways to make new topics easy to access.

usage-example-1.rb
  Creating a theme to track usage. Topics of this theme share the
  buffer and logfile with debugging messages. 

usage-example-2.rb
  Put usage messages into a different file.

dump-example.rb
  Dumping the ring buffer directly to an IO object.

todo-example.rb
  Using Ruby-trace to make executable comments in a program that can
  be used as harder-to-overlook notes to yourself.
