# Allow tests against the recent records table in Timeclock

require 'test/unit/assertions'
include Test::Unit::Assertions

#
# General Code that might be moved to WATIR
#

# Convert the DOM table object into a two-dimensional array. - works with WATIR
def table_array (table, y=[])
  table_rows = table.getElementsByTagName("TR")
  for row in table_rows
    x = []
    for td in row.getElementsbyTagName("TD")
      x << td.innerText.strip
    end
    y << x
  end
  return y
end

#
# Timeclock Specific
#

# Timeclock results table
class RecentRecordsArray < Array
  def job_name index
    self[index][0]
  end
  def status index
    self[index][3]
  end
end

def get_results_table_array (document=$ie.document)
  tables = document.getElementsByTagName("TABLE")
  results_table = tables.item(tables.length - 1) # last
  result = table_array(results_table, RecentRecordsArray.new)
#  assert_equal ["Recent Records"], result[0]
  result
end

def assert_total_job_records( n , document=$ie.document) 
  assert_equal n+1, get_results_table_array(document).length
end

def assert_job_record( index, name, status, document=$ie.document)
  results = get_results_table_array(document)
  assert_equal name, results.job_name( index )
  assert_equal status, results.status( index )
end
