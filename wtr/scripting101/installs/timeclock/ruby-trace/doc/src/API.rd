=begin
TOP_ROW 
TITLE_ROW
CONTENTS_ROW API

= Trace API

((*On this page, hyperlinks from capitalized words (like ((<Destination>)))
point to descriptions of a class that's part of the API. Hyperlinks from
lowercase words (like ((<threshold|URL:glossary.html#threshold>)))
point to definitions in the ((<glossary|URL:glossary.html>)).*))

A ((<Connector>)) object connects ((<Topics|Topic>)) to
((<Destinations|Destination>)). A Topic is an object with 
((<level methods|URL:glossary.html#level_method>)) such as (({error})) and (({warning})). Those methods take
strings or blocks that produce strings. They convert the strings into
((<Messages|Message>)) and send them to their Destinations. But that
happens only if the Topic's ((<threshold|URL:glossary.html#threshold>)) for that Destination allows
it. Thresholds can be set using the Connector (in which case they
apply to all its Topics) or an individual Topic.

If messages need to be converted into strings, a ((<Formatter>)) is
used. Different types of Destinations initialize the Formatter
differently to get terser or more verbose output.

Different Destinations do different things. A ((<PrintingDestination>))
prints to standard output. A ((<BufferDestination>)) maintains a ring
buffer of Messages, which are drained when needed. A
((<LogfileDestination>)) prints to a file, which may be timestamped
and may use version numbers.

A ((<Theme>)) is an ordered list of ((<level|URL:glossary.html#level>)) names. When a Topic is created, it
is given a particular theme (such as "((<debugging|URL:glossary.html#debugging_theme>))"). Its level methods
are constructed from the Theme's level names.

= Errors
The methods described below do considerable error checking of their
arguments, which is generally not described. When they find an error,
they throw a (({Trace::Exception})) that contains a helpful error message.

= Connector
  require 'ruby-trace/connector'

  # creation
  conn = Connector.new { ... }
  conn = Connector.debugging_buffer { ... }
  conn = Connector.debugging_buffer_and_file('logfile.txt', ...) { ... }
  conn = Connector.debugging_printer { ... }
  
  # utilities for use when creating connector objects.
  Connector.new {
    add_theme('my_theme', %w{level1 level2}, :default)
    add_destination(Destination.new('my_destination'), :default)
    theme_and_destination_use_default('my_theme', 'my_destination', 'level1')
    use_environment_variable 'TRACEENV'
 
    debugging_theme
    debugging_theme_and_buffer
  }

  # instance methods
  conn.topic 'my_topic'
  conn.add_method_for_topic 'my_topic'

  conn.replace_destination(Destination.new('my_destination'))
  conn.drain('my_destination', 'his_destination')

  conn.topic_named 'my_topic
  conn.destination_named 'my_destination'
  
== Description

A Connector mainly exists to connect ((<Topics|Topic>)) to ((<Destinations|Destination>)). Most
often, there is one Connector per program. It's usually assigned to a
global like (({$trace})) or made accessible via an instance method of
(({Object})). See ((*'ruby-trace/start/global.rb'*)) and
((*'ruby-trace/start/method.rb'*)) for examples.

If the Connector has been assigned a default ((<Theme>)), it is itself a
Topic with the name ((*''*)). 

If you prefer the spelling "Connecter", you can use that instead. 

== Class Methods
--- Connector.new {optionalBlock}
    Create a new Connector. If the (({optionalBlock})) is specified it
    is run in the context of the new Connection instance. The block should
    create ((<Themes|Theme>)), ((<Destinations|Destination>)), and
    ((<Topics|Topic>)) and connect them to each other. See below for
    useful methods.

    If a default theme is provided, the Connector itself will be a
    Topic that can be sent ((<trace messages|URL:glossary.html#trace_message>)).

    Unless (({optionalBlock})) uses
    ((<(({Connector#use_environment_variable}))>)), the Connector pays no
    attention to the environment.

--- Connector.debugging_buffer {optionalBlock}
    Create a Connector with a 
    ((<debugging theme|URL:glossary.html#debugging_theme>)) 
    as the default ((<Theme>)). ((<Topics|Topic>)) of that Theme are by default
    connected to a ((<BufferDestination>)) named (({'buffer'})).

    The default threshold for the debugging buffer is (({event})).

    If the optional block is given, it's run after the destination is
    created. 

    This connector obeys the environment variable TRACEENV.

--- Connector.debugging_buffer_and_file(*file_args) {optionalBlock}
    Create a Connector with a 
    ((<debugging theme|URL:glossary.html#debugging_theme>)).
    ((<Topics|Topic>)) of that theme are by default
    connected to both a ((<BufferDestination>)) named (({'buffer'}))
    and a ((<LogfileDestination>)) named (({'file'})). The
    (({'file'})) destination is passed the (({file_args})).

    The default threshold for the buffer is (({event})). For the
    logfile, it's (({announce})).

    If the optional block is given, it's run after the buffer and file
    destinations are created.

    This connector obeys the environment variable TRACEENV.

--- Connector.debugging_printer {optionalBlock}
    Create a Connector with a 
    ((<debugging theme|URL:glossary.html#debugging_theme>)).
    ((<Topics|Topic>)) of that theme are by default
    connected to a ((<PrintingDestination>)) named (({'printer'})).

    The default threshold for the buffer is (({none})), so no trace
    messages are normally printed.

    If the optional block is given, it's run after the destination is
    created. 

    This connector obeys the environment variable TRACEENV.

== Creation utilities

These are instance methods used in blocks of the creation methods
described above.

--- Connector#add_theme(themeName, levelArray, optionalDefault)
    Add a Theme with the given ((|themeName|)) to the
    Connector. ((|levelArray|)) is an array of strings. Each is a
    level for the theme, least specific first. ((|optionalDefault|)),
    if non-nil, means that the Theme is the default for Topics created
    on this Connection. There may be only one default theme. 

--- Connector#add_destination(destination, optionalDefault)
    Add a ((<Destination>)) to the Connector. ((|optionalDefault|)),
    if non-nil, means that the ((|destination|)) will be one of the
    default destinations for Topics created on this Connection.

--- Connector#theme_and_destination_use_default(themeName, destinationName, levelName)
    ((<Messages|Message>)) from any ((<Topic>)) with ((|themeName|)) as its
    ((<Theme>)) destined for the ((<Destination>)) named by ((|destinationName|)) will use the
    ((|levelName|)) as their
    ((<threshold|URL:glossary.html#threshold>)), unless it is  
    overridden by topic-specific thresholds.

    You needn't connect each Theme to each
    Destination. However, any attempt to create a topic (with
    ((<(({Connector#topic}))>))) using unconnected Themes and Destinations
    will result in an error.

--- Connector#use_environment_variable(aString)
    Tell the connector to obey the given environment variable. For the
    format of the variable's value, see ((<More on control of
    thresholds|URL:server-programs.html#more_on_control_of_thresholds>)).

    If there's only one Connector in a program, it by convention obeys
    the environment variable TRACEENV. 
    
--- Connector#debugging_theme
    Add the standard ((<debugging theme|URL:glossary.html#debugging_theme>)).

--- Connector#debugging_theme_and_buffer
    Add the standard 
    ((<debugging theme|URL:glossary.html#debugging_theme>)), together with a 
    ((<BufferDestination>)) that is the default destination. Its
    threshold is (({event})).

== Instance Methods
--- Connector#topic(topicName, keywordArgs)
    Create a ((<Topic>)). With no ((|keywordArgs|)), the Topic uses
    the default theme and sends messages to the default
    destinations. Here are the keywords:
    : 'destination' => ((|destinationName|))
      The ((|destinationName|)) overrides the default destination(s).
    : 'destinations' => ((|destinationArray|))
      The ((|destinationArray|)) is an array of destination
      names. They override the default destination(s).
    : 'theme' => ((|themeName|))
      The ((|themeName|)) overrides the default.
    The same ((|topicName|)) can be used more than once. Each call
    returns the same object.

--- Connector#add_method_for_topic(topicName)
    Create a singleton method on the Connector. Its name is
    ((|topicName|)) and its value is the ((<Topic>)) with that name. The
    Topic must have previously been created. A Topic may be added more
    than once; the later additions have no effect. 

    These methods are referred to as 
    ((<level methods|URL:glossary.html#level_method>)).

--- Connector#replace_destination(destination)
    The argument is a ((<Destination>)). Its name is that of a
    Destination previously added with
    ((<(({Connector#add_destination}))>)). That Destination is replaced.

--- Connector#drain(sourceDestination, sinkDestination)
    The ((|sourceDestination|)) is the name of a Destination that
    responds to the message (({to_destination})) (currently only
    ((<BufferDestination>))). Each ((<Message>)) from the source is
    sent to the Destination named by ((|sinkDestination|)).

--- Connector#topic_named(name)
    Return the ((<Topic>)) named by ((|name|)). 
--- Connector#destination_named(name)
    Return the ((<Destination>)) named by ((|name|)). 

= Topic
  require 'ruby-trace/topic'

  # Creation
  topic = connector.topic('name')

  # instance methods
  topic.set_threshold('buffer', 'error')
  topic.set_default_threshold('buffer', 'verbose')

  # singleton methods
  topic.level 'string'
  topic.level { 'string' }
  topic.level_value { 'variable' }

== Description 
A Topic object has singleton 
((<level methods|URL:glossary.html#level_method>)) determined by the
levels of its ((<Theme>)). These methods check whether any of the
((<thresholds|URL:glossary.html#threshold>)) for the Topic's ((<Destinations|Destination>)) allow
messages of that level to pass. If so, a ((<Message>)) object is
created and handed to whichever Destinations have the allowing
threshold. 

The methods have three formats. 

: ((|level|))(aString, optionalOffset)
  The string is the body of the message.
: ((|level|))(optionalOffset) { blockReturningString }
  If the Topic's thresholds allow, the block is evaluated
  to obtain the body of the message.
: ((|level|))_value { expression }
  If the Topic's thresholds allow, the body of the message is
  ((|expression|)) as a string, followed by its value. For example,
  (({{"a"}})) will produce (({"a -> 5"})) if (({a})) has the value 5.

When Ruby-trace is used for debugging, a Topic is normally a subsystem
(such as 'gui', 'net', etc.)

Normally, trace messages are identified as coming from the caller of
the ((<level method|URL:glossary.html#level_method>)). If the
((|optionalOffset|)) is 1, they're identified as
coming from the caller of the caller of the level method. This allows
you to wrap level methods and still get useful locations in the trace
output. 

A Topic's threshold can be controlled independently of all other
topics. 

Topics should not be created directly. Create them with
((<(({Connector#topic}))>)).

== Instance Methods
--- Topic#set_threshold(destinationName, levelName)
    Set the Topic's ((<threshold|URL:glossary.html#threshold>)) for
    ((|destinationName|)) to 
    ((|levelName|)). There are two special values for ((|levelName|)):
    : none
      No Messages will be passed to the destination.
    : default
      Set the threshold to its default value (presumably after
      changing it with an earlier call to (({set_threshold}))).

--- Topic#set_default_threshold(destinationName, levelName)
    Set the Topic's default
    ((<threshold|URL:glossary.html#threshold>)) for
    ((|destinationName|)) to 
    ((|levelName|)). This is the level that (({set_threshold(dest,
    'default'}))) uses. As a special case,
    (({set_default_threshold(dest, 'default')})) defers to the
    ((<Connector>)) that was used to create this Topic. That Connector has a
    global default threshold that controls all messages from Topics of
    a particular Theme to a particular Destination. See
    ((<(({Connector#theme_and_destination_use_default}))>)). 

= Destination
  require 'ruby-trace/destination'

  dest = Destination.new('name')
  dest.accept(message)

== Description
Destination is an abstract superclass. 

== Class Methods
--- Destination.new(stringName)
    All Destinations have names. After they are added to a Connector,
    they are referred to by their ((|stringName|)).
== Instance Methods
--- Destination#accept(message)
    Every Destination accepts a ((<Message>)) and puts it
    somewhere. Where "somewhere" is depends on the subclass. 
= PrintingDestination
  require 'ruby-trace/destination'

  print_dest = PrintingDestination.new('printer')
  print_dest.formatter = Formatter.new
  print_dest.accept(message)
  
== Description
Formats the message according to its ((<Formatter>)) and puts it to
(({$defout})). Unless the Formatter is changed, the output looks like
this: 

  print-example.rb:21:in `initialize'
  = topic announce: The body of the message.

== Class Methods
--- PrintingDestination.new(stringName)
    Creates the printing Destination.

== Instance Methods
--- PrintingDestination.formatter=(aFormatter)
    Changes the Formatter used.

= BufferDestination
  require 'ruby-trace/destination'

  buf_dest = BufferDestination.new('buffer')

  buf_dest.accept(message)
  buf_dest.limit=1000
  buf_dest.clear
  buf_dest.messages

  buf_dest.to_IO(anIO, formatter)
  buf_dest.to_destination(destination)  

== Description
A BufferDestination is a ring buffer that stores a limited number of
((<Messages|Message>)). The messages can be sent to an (({IO})) or
another Destination. They are not formatted until they are sent.
== Class Methods
--- BufferDestination.new(stringName)
    Creates a BufferDestination that can hold 100 messages.

== Instance Methods
--- BufferDestination.limit=(anInteger)
    Change the number of messages the buffer can hold to
    ((|anInteger|)), which must be greater than 0. If the new limit is
    smaller than the number of messages in the buffer, the oldest are
    discarded. 

--- BufferDestination.clear
    Empty the buffer of all messages.

--- BufferDestination.messages
    Return the Messages in the buffer as an array. Messages are in the
    order they were created. If the buffer is
    not full, the array will be smaller than the buffer's limit.

--- BufferDestination.to_IO(anIO, optionalFormatter)
    Format the Messages and print them (with (({puts}))) to
    ((|anIO|)). If ((|optionalFormatter|)) is not given, the two-line format
    used by ((<PrintingDestination>)) is used. 

--- BufferDestination.to_destination(destination)
    Each Message in the buffer is given to ((|destination|))'s
    (({accept})) method. Note that ((|destination|)) is a Destination,
    not the name of one.  

= LogfileDestination
  require 'ruby-trace/destination'

  dest = LogfileDestination.new('file', 'Tracelog.%t%b.txt', 'a', 1000000, '010')

  dest.accept(message)
  dest.limit=1000000
  dest.formatter = Formatter.new
  dest.filename
  dest.reopen
  dest.close

== Description
A LogfileDestination is a file. It may optionally have a timestamp in
its name. It may have a limited size, in which case a number of backup
files may be created. See the
((<discussion|URL:server-programs.html#backup_files>)) in the
documentation for ((<server programs|URL:server-programs.html>)).

If the LogFileDestination's Formatter is not changed, the file will
contain messages that look like this:

  topic-example.rb:10 at 2001/07/20 00:27:27
  = accounting error: Impossible event explode in state crashed.

== Class Methods
--- LogfileDestination.new(stringName, optionalFilename, optionalMode, optionalLimit, optionalGreatestBackupTag)
    Open the destination. 
    If the ((|optionalFilename|)) is not given, it is "Tracelog.txt". 
    If the ((|optionalMode|)) is not given, it is "w"
    (clear file on open). Otherwise, it must be "a" (append). 
    If the ((|optionalLimit|)) is not given, the destination is of
    unlimited size.
    If the ((|optionalGreatestBackupTag|)) is not given, it is '000'.

    If the ((|optionalFilename|)) contains the string "%t", those two
    characters are replaced with a timestamp in the format
    YYYYMMDDHHMMSS. 

    If the ((|optionalFilename|)) contains the string "%b" and opening
    the logfile would overwrite an existing file, that existing file
    is backed up to a name where "%b" is replaced with a string in the 
    range '.000' .. .((|optionalGreatestBackupTag|)). The string chosen
    is the successor of that used by the current youngest file,
    wrapping around if needed. 

    Note that "%b" adds a period to the
    front of the three-digit string. That way, "Tracelog%b.txt" will
    create files "Tracelog.txt" and "Tracelog.000.txt", 

== Class Constants
--- LogfileDestination::Infinity
    Used to open a logfile with unlimited size. 

== Instance Methods
--- LogfileDestination#limit=(anInteger)
    Set the size limit to ((|anInteger|)). Note that the limits are
    only approximate. That's because I didn't have the energy to write
    code to figure out
    that we're on Windows and count when a newline is converted into two
    characters. 

--- LogfileDestination#formatter=(aFormatter)
    Use ((|aFormatter|)) when formatting output.
    
--- LogfileDestination#filename
    This is the filename with "%t" expanded and "%b" stripped out.

--- LogfileDestination#reopen
    Close the logfile and reopen it to a file of the same name. If the
    filename given to the constructor contained a "%b", a backup file
    is created.

--- LogfileDestination#close
    Close the (({File})) associated with the destination. Once closed,
    it should not be reopened.

= Formatter
  require 'ruby-trace/formatter'

  formatter = Formatter.new('"#{time}: #{body}"', "%a, %b %d")
  formatter.accept(message)
  
== Description
A formatter is initialized with up to two strings that describe how a
((<Message>)) should be formatted. It produces strings formatted
accordingly. 
== Class Methods
--- Formatter.new(messageFormat, timeFormat)
    The ((|messageFormat|)) is a string with expressions that will be
    substituted ((*in the context of the Formatter*)). The Formatter's
    ((<accept|Formatter#accept>)) method makes available certain
    variables that are useful in constructing output. These are:
    : time 
      The time the Message was created, formatted according to
      ((|timeFormat|)). 
    : location
      The line where the ((<trace message|URL:glossary.html#trace_message>))
      was sent. (For example, the place where (({$trace.error 'oops'})) is
      sent.) Formatted as in
      Ruby stack backtraces and compiler error messages.
    : level
      The name of the
      ((<level method|URL:glossary.html#level_method>)) (error, warning, etc.)
    : topic
      The name of the ((<Topic>)) the trace message was sent to. 
    : body
      The string that was the argument to the level method (or
      resulted from evaluating the block associated with the method). 

    Because ((|messageFormat|)) is to be evaluated in the context of the
    Formatter, it must be "double-quoted" to prevent substitution in
    the caller's context. That is, "#{time}: #{body}" would not be
    correct because #{time} would be substituted with the value of a
    variable (({time})) local to the method that calls
    (({Formatter.new})). '"#{time}: #{body}"' (with surrounding single
    quotes) works as intended.

    ((|timeFormat|)) is used to format the (({time})) variable before
    it's substituted into the (({messageFormat})). It is a string of
    the form accepted by (({Time#strftime})). 

== Class Constants
--- Formatter::TWO_LINE
    The default ((|messageFormat|)).

    '"#{location}#{$/}= #{topic} #{level}: #{body}"'
--- Formatter::TWO_LINE_WITH_DATE
    The kind of ((|messageFormat|)) used by ((<(({LogfileDestination}))>)). 
    
    '"#{location} at #{time}#{$/}= #{topic} #{level}: #{body}"'
--- Formatter::VERBOSE_SORTABLE_TIME
    The kind of ((|timeFormat|)) used by LogfileDestination. Most
    significant time units come first. 

    "%Y/%m/%d %H:%M:%S"

== Instance Methods
--- Formatter#accept(message)
    The message is formatted and the resulting string is returned. 

= Message
  require 'ruby-trace/message'

((<Topics|Topic>)) hand Messages to
((<Destinations|Destination>)). Messages capture the information
available when a ((<trace message|URL:glossary.html#trace_message>))
is sent, such as the line number it was sent from. For a list of that 
information, see ((<(({Formatter.new}))>)).

Since I don't think you ever want to create or use Messages directly, they're
not further described. 

= Theme
  require 'ruby-trace/misc'

A Theme is essentially a list of level names. The level names
determine which trace level methods a Topic responds to. 

Themes are created with ((<Connector#add_theme>)). You should never
need to access Themes directly.

CONTENTS_ROW API
END_MATTER
=end
