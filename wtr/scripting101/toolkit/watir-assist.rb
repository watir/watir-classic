require 'toolkit/watir'

def ie_load ( html_file )
  path = File.join( File.dirname(__FILE__), html_file ) # relative path
  path = File.expand_path( path ) # full path
  path.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  $ie = IE.new
  $iec = $ie
  $ie.goto( 'file://' + path )
  return $ie
end

def get_document()
  $ie.getDocument
end

