# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.


### Assertions
###
### Assertion checking messages take blocks that produce strings. The 
### blocks are only evaluated in case of error:
### 
### TraceErrors.assert(2 + 2 == 4, { "Welcome to 1984" }
### assert(2 + 2 == 4, { "Welcome to 1984" }
###
### Blocks appear faster than even simple strings, much less strings
### with formatting.
###
### Fail messages just take strings, since we know it's a case of error.
###
### TraceErrors.fail "oops"
### fail "oops"
###
### Upon failure, a Trace::Exception is thrown with the given string as
### its message.

module TraceErrors
  # These are for use in class methods.

  def TraceErrors.assert (bool)
    fail(yield) unless bool
  end

  def TraceErrors.fail(msg)
    raise(Trace::Exception, msg) 
  end

  # For use as a mixin.
  # If there's a way to do this with aliasing, someone let me know.
  def assert (bool)
    fail(yield) unless bool
  end

  def fail(msg)
    raise(Trace::Exception, msg)
  end

end
