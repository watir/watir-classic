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



