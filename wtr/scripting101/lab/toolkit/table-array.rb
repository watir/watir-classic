def table_array (table, y=[])
  "Convert the DOM table object into a two-dimensional array."
  table_rows = table.getElementsByTagName("TR")
  for row in table_rows
    x = []
    for td in row.getElementsbyTagName("TD")
      x << td.innerHtml
    end
    y << x
  end
  return y
end

class RecentRecordsArray < Array
  def job_name index
    self[index][0].strip
  end
  def status index
    self[index][3].strip
  end
end

def get_results_table_array
  tables = $iec.document.getElementsByTagName("TABLE")
  results_table = tables.item(tables.length - 1) # last
  result = table_array(results_table, RecentRecordsArray.new)
#  assert_equal ["Recent Records "], result[0]
  result
end

def assert_total_job_records(n)
  assert_equal n+1, get_results_table_array.length
end

def assert_job_record( index, name, status)
  results = get_results_table_array
  assert_equal name, results.job_name(index)
  assert_equal status, results.status(index)
end



