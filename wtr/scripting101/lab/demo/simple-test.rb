require '../toolkit'

# Start with a user that has no time records. 
ensure_no_user_data('ruby')

# Go to the application home page
start_ie('http://localhost:8080')

# Login with user 'ruby'
forms[0].name = 'ruby'
forms[0].submit
$iec.wait

# Create a background job
def new_job 
  form{|f| f.action == 'job'}
end
new_job.name = 'background'
new_job.submit
$iec.wait

# Create two jobs
new_job.name = 'job1'
new_job.submit
$iec.wait

new_job.name = 'job2'
new_job.submit
$iec.wait

# Record time sessions for two separate jobs, one session for each.
form{|f| f.action == 'start'}.element{|e| e.value == 'job1'}.click
sleep 1
form{|f| f.action == 'start'}.element{|e| e.value == 'job2'}.click
sleep 1

form{|f| f.action == 'pause_or_stop_job' }.elements('quick_stop').click
$iec.wait
form{|f| f.action == 'pause_or_stop_day' }.elements('stop_day').click
$iec.wait

# Verify that two time records appear.
assert_total_job_records 2
recent_records = get_results_table_array
assert_equal('Recent Records ', recent_records[0][0])
assert_equal('job2 ', recent_records[1][0])
assert_equal('job1 ', recent_records[2][0])

# Display the time records
tables = $iec.document.getElementsByTagName('TABLE')
results_table = tables.item(tables.length - 1) # last table
table_rows = results_table.getElementsByTagName('TR')

for row in table_rows
  for td in row.getElementsbyTagName('TD')
    puts td.innerHtml
  end
end
    
  


