require 'toolkit'
start_ie ("http://localhost:8080")

# Login page
login_form = get_forms[0]
login_form.name = "Erik"
login_form.submit
@iec.wait

# First Job
get_forms[0].name = "writing documentation"
get_forms[0].submit
@iec.wait

# Main Page
job_form = get_form_by_action("job")
job_form.name = "learning"
job_form.submit
@iec.wait

all_jobs = get_form_by_action("start")
get_element_by_value(all_jobs, "learning").click
@iec.wait

# verify that the job record appears in the bottom
tables = @iec.document.getElementsByTagName("TABLE")
results_table = tables.item(tables.length - 1) # last table
require 'toolkit/table-array'
a = table_array(results_table)

if a[1][0] == "learning "
  print "PASS"
else
  print "FAIL"
end

if a[1][3] == "<B>running</B> "
  print "PASS"
else
  print "FAIL"
end
