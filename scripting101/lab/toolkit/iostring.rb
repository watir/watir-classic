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

  def expect string
    assert_equal string, @mockout.readline!.strip
  end
  def expect_match regexp
    assert_match regexp, @mockout.readline!.strip
  end

def ie_load ( html_file )
  path = File.join( File.dirname(__FILE__), html_file ) # relative path
  path = File.expand_path( path ) # full path
  path.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  start_ie( 'file://' + path, false )
end

