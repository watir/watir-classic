require "stringio"

module CaptureIOHelper
  
  def capture_stdout(&blk)
    old = $stdout
    $stdout = io = StringIO.new
    
    yield
    
    io.string
  ensure
    $stdout = old
  end
end    


