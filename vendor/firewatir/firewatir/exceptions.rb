module FireWatir
  module Exception

    # Root class for all FireWatir Exceptions
    class FireWatirException < RuntimeError  
        def initialize(message="")
            super(message)
        end
    end

    # This exception is thrown if we are unable to connect to JSSh.
    class UnableToStartJSShException < FireWatirException; end
    # This exception is thrown if an attempt is made to access an object that doesn't exist
    class UnknownObjectException < FireWatirException; end
    # This exception is thrown if an attempt is made to access an object that is in a disabled state
    class ObjectDisabledException   < FireWatirException; end
    # This exception is thrown if an attempt is made to access a frame that cannot be found 
    class UnknownFrameException< FireWatirException; end
    # This exception is thrown if an attempt is made to access a form that cannot be found 
    class UnknownFormException< FireWatirException; end
    # This exception is thrown if an attempt is made to access an object that is in a read only state
    class ObjectReadOnlyException  < FireWatirException; end
    # This exception is thrown if an attempt is made to access an object when the specified value cannot be found
    class NoValueFoundException < FireWatirException; end
    # This exception gets raised if part of finding an object is missing
    class MissingWayOfFindingObjectException < FireWatirException; end
    # this exception is raised if an attempt is made to  access a table cell that doesnt exist
    class UnknownCellException < FireWatirException; end
    # This exception is thrown if the window cannot be found
    class NoMatchingWindowFoundException < FireWatirException; end
    # This exception is thrown if an attemp is made to acces the status bar of the browser when it doesnt exist
    class NoStatusBarException < FireWatirException; end
    # This exception is thrown if an http error, such as a 404, 500 etc is encountered while navigating
    class NavigationException < FireWatirException; end
    # This exception is raised if a timeout is exceeded
    class TimeOutException < FireWatirException
      def initialize(duration, timeout)
        @duration, @timeout = duration, timeout
      end 
      attr_reader :duration, :timeout
    end
    
  end
end
