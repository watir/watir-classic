require 'toolkit'
start_ie 

# Login page
login_form = forms[0]
login_form.name = "Erik"
login_form.submit
wait

# First Job
forms[0].name = "writing documentation"
forms[0].submit
wait

# Main Page
job_form = form{|f| f.action == 'job'}
job_form.name = 'learning'
job_form.submit
wait

all_jobs = form{|f| f.action == 'start'}
all_jobs.element{|e| e.value == 'learning'}.click
wait

# verify that the job record appears in the bottom
tables = $iec.document.getElementsByTagName("TABLE")
results_table = tables.item(tables.length - 1) # last table
require 'toolkit/timeclock-recent-records'
a = table_array(results_table)

if a[1][0] == "learning"
  print "PASS"
else
  print "FAIL"
end

if a[1][3] == "running"
  print "PASS"
else
  print "FAIL"
end
