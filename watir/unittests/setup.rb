logger = WatirLogger.new('test.txt' ,5, 65535 * 2)
$ie = IE.new(logger)
$myDir = File.expand_path(File.dirname(__FILE__))
$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
$htmlRoot =  "file://#{$myDir}/html/" 
#   $htmlRoot =  "http://localhost:8080/watir/html/"