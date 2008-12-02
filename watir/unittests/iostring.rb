# class useful for testing output to stdout
class IOString < String
  def write x
    self.<< x
  end
  def readline!
    line = slice!(/^.*(\n|$)/)
    if $1 == "\n" then line.chop! 
    elsif line == "" then nil 
    else line 
    end
  end
  def puts( x ) 
    stdout_orig = $stdout
    $stdout = self
    Kernel.puts x 
    $stdout = stdout_orig
  end
end

module MockStdoutTestCase
  def setup
    @mockout = IOString.new ""
  end
  def teardown
    $stdout = STDOUT
  end
end    


