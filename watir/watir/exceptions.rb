module Watir
  module Exception

    # Root class for all Watir Exceptions
    class WatirException < RuntimeError  
        def initialize(message="")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access an object that doesn't exist
    class UnknownObjectException < WatirException
        def initialize(message="")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access a property that either does not exist or has not been found
    class UnknownPropertyException < WatirException
        def initialize(message = "")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access an object that is in a disabled state
    class ObjectDisabledException   < WatirException
        def initialize(message="")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access a frame that cannot be found 
    class UnknownFrameException< WatirException
        def initialize(message = "")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access a form that cannot be found 
    class UnknownFormException< WatirException
        def initialize(message="")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access an object that is in a read only state
    class ObjectReadOnlyException  < WatirException
        def initialize(message = "")
            super(message)
        end
    end
    
    # This exception is thrown if an attempt is made to access an object when the specified value cannot be found
    class NoValueFoundException < WatirException
        def initialize(message = "")
            super(message)
        end
    end
    
    # This exception gets raised if part of finding an object is missing
    class MissingWayOfFindingObjectException < WatirException
        def initialize(message="")
            super(message)
        end
    end
    # This exception is raised if an attempt is made to access a table that doesn't exist
    class UnknownTableException < WatirException
        def initialize(message="")
            super(message)
        end
    end

    # this exception is raised if an attempt is made to  access a table cell that doesnt exist
    class UnknownCellException < WatirException
        def initialize(message="")
            super(message)
        end
    end

    
    # This exception is thrown if the window cannot be found
    class NoMatchingWindowFoundException < WatirException
        def initialize(message="")
            super(message)
        end
    end

    # This exception is thrown if an attemp is made to acces the status bar of the browser when it doesnt exist
    class NoStatusBarException < WatirException
        def initialize(message="")
            super(message)
        end
    end

    # This exception is thrown if an http error, such as a 404, 500 etc is encountered while navigating
    class NavigationException < WatirException
        def initialize(message="")
            super(message)
        end
    end

  end
end