# Assertions for program errors.
class ProgramError < StandardError
end

def flunk(message)
  raise ProgramError, message
end

def assert(bool, message="Internal program error")
  flunk(message) unless bool
end

