# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

# This module loads up everything, then turns on internal tracing.
module Trace
  # This null object receives messages from the trace subsystem itself
  # during loading.
  class NullTrace
    def method_missing(methodId, *args)
    end
  end

  # Seems most convenient way to make a trace-specific trace
  # variable available to all classes. Trace classes send to 
  # Internal.trace.event, etc. 
  class Internal
    @@trace=NullTrace.new

    def Internal.trace
      @@trace
    end
  end
end

require 'ruby-trace/errors'
require 'ruby-trace/message'
require 'ruby-trace/valueholder'
require 'ruby-trace/destination'
require 'ruby-trace/topic'
require 'ruby-trace/misc'
require 'ruby-trace/connector'
require 'ruby-trace/formatter'

module Trace
  class Internal
    conn=Trace::Connector.debugging_printer
    @@trace=conn.topic('trace')
  end

end



