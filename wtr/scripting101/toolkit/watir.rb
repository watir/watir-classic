# load the real watir library

# first the CVS path
$LOAD_PATH.unshift File.join( File.dirname( __FILE__ ), '..', '..', '..', 'watir' )

# second the packaged installation
$LOAD_PATH << File.join( File.dirname( __FILE__ ), '..', '..', 'watir' )

require 'watir'

def get_document()
  $ie.getDocument
end

