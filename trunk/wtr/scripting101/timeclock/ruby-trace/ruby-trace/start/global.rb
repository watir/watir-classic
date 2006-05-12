# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Tag$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

# Load this, and you get ruby-trace plus a global that prints
# debugging-themed output to stdout.

require 'ruby-trace/all'

$trace = Trace::Connector.debugging_printer

