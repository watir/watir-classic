require 'watir'

def ie_load ( html_file )
  path = File.join( File.dirname(__FILE__), html_file ) # relative path
  path = File.expand_path( path ) # full path
  path.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  $ie = Watir::IE.new
  $ie.goto( 'file://' + path )
  return $ie
end



