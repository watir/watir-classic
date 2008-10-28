# setup/browser
require 'watir/browser'
case Watir.options[:browser]
when 'ie'
  at_exit {Watir::IE.quit}
  $LOAD_PATH.unshift File.expand_path($watir_dev_lib)
when 'firefox'
  $LOAD_PATH.unshift File.expand_path($firewatir_dev_lib)
end
$browser = Watir::Browser.new

# close browser at completion of the tests
# the at_exit execute before loading test/unit, otherwise IE will close *before* the tests run.
at_exit {$browser.close if $browser}

