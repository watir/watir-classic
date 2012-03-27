module Watir
  include Watir::Exception

# Directory containing the watir.rb file
  @@dir = File.expand_path(File.dirname(__FILE__))

# Like regular Ruby "until", except that a Wait::TimeoutError is raised
# if the timeout is exceeded. Timeout is IE.attach_timeout.
  def self.until_with_timeout # block
    Wait.until(IE.attach_timeout) { yield }
  end
end