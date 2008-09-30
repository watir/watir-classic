case Watir::UnitTest.options[:browser]
when 'ie'
  $LOAD_PATH.unshift File.expand_path($watir_dev_lib)
  require 'watir'
  # this line must execute before loading test/unit, otherwise IE will close *before* the tests run.
  at_exit {$ie.close if $ie && $ie.exists?; Watir::IE.quit} # close ie at completion of the tests
  speed = Watir::UnitTest.options[:speed].to_sym
  Watir::IE.speed = speed
  $ie = Watir::IE.new
  $ie.speed = speed
  $browser = $ie
when 'firefox'
  $LOAD_PATH.unshift File.expand_path($firewatir_dev_lib)
  require 'firewatir'
  at_exit {$browser.close if $browser}
  $browser = FireWatir::Firefox.new
end
