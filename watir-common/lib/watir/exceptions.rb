module Watir
  module Exception

    # Root class for all Watir Exceptions
    class WatirException < RuntimeError  
        def initialize(message="")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access an object that doesn't exist
    class UnknownObjectException < WatirException; end
    # This exception is thrown if an attempt is made to access an object that is in a disabled state
    class ObjectDisabledException   < WatirException; end
    # This exception is thrown if an attempt is made to access a frame that cannot be found 
    class UnknownFrameException< WatirException; end
    # This exception is thrown if an attempt is made to access a form that cannot be found 
    class UnknownFormException< WatirException; end
    # This exception is thrown if an attempt is made to access an object that is in a read only state
    class ObjectReadOnlyException  < WatirException; end
    # This exception is thrown if an attempt is made to access an object when the specified value cannot be found
    class NoValueFoundException < WatirException; end
    # This exception gets raised if part of finding an object is missing
    class MissingWayOfFindingObjectException < WatirException; end
    # this exception is raised if an attempt is made to  access a table cell that doesnt exist
    class UnknownCellException < WatirException; end
    # This exception is thrown if the window cannot be found
    class NoMatchingWindowFoundException < WatirException; end
    # This exception is thrown if an attemp is made to acces the status bar of the browser when it doesnt exist
    class NoStatusBarException < WatirException; end
    # This exception is thrown if an http error, such as a 404, 500 etc is encountered while navigating
    class NavigationException < WatirException; end
    # This exception is raised if a timeout is exceeded
    class TimeOutException < WatirException
      def initialize(duration, timeout)
        @duration, @timeout = duration, timeout
      end 
      attr_reader :duration, :timeout
    end

    # Return an error message for when unable to locate the element
    def self.message_for_unable_to_locate(how, what)
      result = "using #{how.inspect}"
      result << ", #{what.inspect}" if what
      "Unable to locate element, #{result}"
    end    
  end
end