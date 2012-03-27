module Watir
  class WatirLogger < Logger
    def initialize(filName, logsToKeep, maxLogSize)
      super(filName, logsToKeep, maxLogSize)
      self.level = Logger::DEBUG
      self.datetime_format = "%d-%b-%Y %H:%M:%S"
      self.debug("Watir starting")
    end
  end
  
  class DefaultLogger < Logger
    def initialize
      super(STDERR)
      self.level = Logger::WARN
      self.datetime_format = "%d-%b-%Y %H:%M:%S"
      self.info "Log started"
    end
  end
end
