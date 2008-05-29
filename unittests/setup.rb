# libraries used by feature tests
require 'watir'
END {$ie.close if $ie && $ie.exists?; Watir::IE.quit} # close ie at completion of the tests

require 'test/unit'
require 'watir/testcase'

# Better would be to add this to a module that was included in all the tests.
class Test::Unit::TestCase
  def use_page page
    browser.goto($htmlRoot + page)
  end
  def browser
    $ie
  end
end

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
  $xpath_tests = Dir["unittests/*_xpath_test.rb"]
end

$window_tests =
    ['js_events', # is always visible
     'modal_dialog', # modal is visible
     'attach_to_existing_window', # could actually run robustly as part of the core suite!
     'attach_to_new_window', # creates new window
     'jscript',
     'send_keys', # visible
     'iedialog', # visible
     'close_window', # creates new window
     'frame_links', # visible
     'open_close',
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

$ie = Watir::IE.new
$ie.speed = :fast

$myDir = File.expand_path(File.dirname(__FILE__))
$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
# if you run the unit tests form a local file system use this line
$htmlRoot =  "file://#{$myDir}/html/" 
# if you run the unit tests from a web server use this line
#   $htmlRoot =  "http://localhost:8080/watir/html/"
