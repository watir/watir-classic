$SETUP_LOADED = true
$myDir = File.expand_path(File.dirname(__FILE__))

require 'user-choices'

module Watir
  class UnitTestOptions < UserChoices::Command
    include UserChoices
    def add_sources builder
      builder.add_source EnvironmentSource, :with_prefix, 'watir_'
      builder.add_source YamlConfigFileSource, :from_complete_path, 
        $myDir + '/options.yml' 
    end
    def add_choices builder
      builder.add_choice :browser, :type => ['firefox', 'ie', 'Firefox', 'IE'], 
      :default => 'ie'
      builder.add_choice :speed, :type => ['slow', 'fast', 'zippy'], :default => 'fast'
    end
    def execute 
      @user_choices[:browser].downcase!
      speed = @user_choices[:speed].to_sym
      Watir::IE.speed = speed
      @user_choices
    end
  end
end

# use local development versions of firewatir, watir-common if available
topdir = File.join(File.dirname(__FILE__), '..')
watir_lib = File.join(topdir, 'lib')
firewatir_lib = File.join(topdir, '..', 'firewatir', 'lib')
watir_common_lib = File.join(topdir, '..', 'watir-common', 'lib')
$LOAD_PATH.unshift watir_lib
$LOAD_PATH.unshift firewatir_lib
$LOAD_PATH.unshift watir_common_lib

# libraries used by feature tests
require 'watir'

options = Watir::UnitTestOptions.new.execute
case options[:browser]
when 'ie'
  # this line must execute before loading test/unit, otherwise IE will close *before* the tests run.
  at_exit {$ie.close if $ie && $ie.exists?; Watir::IE.quit} # close ie at completion of the tests
  $ie = Watir::IE.new
  $ie.speed = options[:speed].to_sym
  $browser = $ie
when 'firefox'
  require 'firewatir'
  at_exit {$browser.close if $browser}
  $browser = FireWatir::Firefox.new
end

require 'test/unit'
require 'watir/testcase'

module Watir::UnitTest
  # navigate the browser to the specified page in unittests/html
  def goto_page page
    new_url = $htmlRoot + page
    browser.goto new_url
  end
  # navigate the browser to the specified page in unittests/html IF the browser is not already on that page.
  def uses_page page
    new_url = $htmlRoot + page
    browser.goto new_url unless browser.url == new_url
  end
  def browser
    $browser
  end
end

# a hack
class Test::Unit::TestCase
  include Watir::UnitTest
end

=begin
Test Suites
* all_tests -- all the tests in the unittests directory (omits "other")
* window_tests -- window intensive tests
* non_core_tests -- problem tests
* xpath_tests -- xpath (some problems)
* core_tests -- all others, well behaved
=end

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
  $xpath_tests = Dir["unittests/*_xpath_test.rb"]
end

$window_tests =
    [
     'attach_to_existing_window', # could actually run robustly as part of the core suite!
     'attach_to_new_window', # creates new window
     'close_window', # creates new window
     'frame_links', # visible
     'iedialog', # visible
     #ie-each
     'js_events', # is always visible
     'jscript',
     'modal_dialog', # modal is visible
     #new (named oddly)
     'open_close',
     'send_keys', # visible
    ].collect {|x| "unittests/windows/#{x}_test.rb"}

$non_core_tests = 
    ['popups', # has problems when run in a suite (is ok when run alone); 
               # must be visible
               # will be revised to use autoit 
               # takes 15 seconds to run
     'images', # save file must must be visible
#     'screen_capture', # is always visible; takes 25 seconds
     'filefield', # is always visible; takes 40 seconds 
     'minmax', # becomes visible
     'dialog' # visible
    ].collect {|x| "unittests/#{x}_test.rb"}

$core_tests = $all_tests - $non_core_tests - $window_tests - $xpath_tests

$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
# if you run the unit tests from a local file system use this line
$htmlRoot =  "file:///#{$myDir}/html/" 
# if you run the unit tests from a web server use this line
#   $htmlRoot =  "http://localhost:8080/watir/html/"
