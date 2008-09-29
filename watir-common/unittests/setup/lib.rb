$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos

require 'unittests/setup/options'
require 'unittests/setup/browser'
require 'unittests/setup/filter'
require 'unittests/setup/watir-unittest'
