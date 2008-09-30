$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos

require 'unittests/setup/options'
Watir::UnitTest.options = Watir::UnitTest::Options.new.execute
require 'unittests/setup/browser'
require 'unittests/setup/filter'
require 'unittests/setup/watir-unittest'

options = Watir::UnitTest.options
if options[:coverage] == 'regression'
  tag = "fails_on_#{options[:browser]}".to_sym
  Watir::UnitTest.filter_out_tests_tagged tag
end


