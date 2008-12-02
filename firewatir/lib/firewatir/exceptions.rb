require 'watir/exceptions' # from commonwatir

module Watir
  module Exception
    # This exception is thrown if we are unable to connect to JSSh.
    class UnableToStartJSShException < WatirException; end
  end
end


