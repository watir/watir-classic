# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'observer'
require 'ruby-trace/errors'

module Trace
  # ValueHolders are Observable caches of value that can be told
  # to forget their value. I don't *think* they need to be synchronized. 
  class ValueHolder
    include Observable
    include TraceErrors

    No_value = :NO__VALUE_

    def initialize(value=No_value)
      @value = value
    end

    def value
      assert(value?) { "ValueHolder must have explicit value."}
      @value
    end

    def value=(arg)
      @value=arg
      Internal.trace.verbose("Value updated to #{@value}.")
      changed; notify_observers
    end

    def value?
      @value!=No_value
    end

    def forget_value!
      Internal.trace.verbose("Value forgets value.")
      @value=No_value
      changed; notify_observers
    end

    def inspect
      if value?
        value
      else
        "<no value>"
      end
    end
  end

end
