$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos

require 'unittests/setup/options'
Watir::UnitTest.options = Watir::UnitTest::Options.new.execute
require 'unittests/setup/browser'
require 'unittests/setup/filter'
require 'unittests/setup/watir-unittest'

options = Watir::UnitTest.options
failure_tag = "fails_on_#{options[:browser]}".to_sym
case options[:coverage]
  when 'regression'
  Watir::UnitTest.filter_out_tests_tagged failure_tag
  when 'known failures'
  Watir::UnitTest.filter_out do |test|
    !(test.tagged? failure_tag)
  end
end


