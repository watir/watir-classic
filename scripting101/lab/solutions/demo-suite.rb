require 'test/unit'

class LoadTestScript < Test::Unit::TestCase
  def test_check_records
    load 'check-records.rb'
  end
  def teardown
    $iec.close if $iec
  end
end
