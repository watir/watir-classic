# tests 'timeclock-recent-records.rb' - now works with watir

require 'toolkit/timeclock-recent-records'
require 'test/unit'
require 'toolkit/iostring'

require 'watir'
require 'toolkit/watir-assist'

class TestTable < Test::Unit::TestCase
  def test_table_array

ie_load( 'sample_page.html' )
y = get_results_table_array

ios = IOString.new
ios.puts y

assert_equal( ios, <<END
Recent Records
balloon
12:25 AM
0.00 hours
running
ruby article
12:24 AM
0.01 hours
paused
ruby article
12:18 AM
0.00 hours

END
              )
$ie.close

end

end
