require 'timeclock/marshalled/TimeclockError'
require 'fluid'

module Timeclock
  module Whine

    module_function

    def whine(problem, *args)
      raise TimeclockError.new("User error #{problem}. Further info: #{args.inspect}", problem, args)
    end
      
    def whine_unless(boolean, problem, *args)
      unless boolean
        whine(problem, *args)
      end
    end

    def whine_if(boolean, problem, *args)
      if boolean
        whine(problem, *args)
      end
    end

  end
end
