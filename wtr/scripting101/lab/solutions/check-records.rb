# Suggested solution to Lab 4: Record Check.
require 'toolkit'

# Start with a user that has no time records. 
start_ie 'http://localhost:8080'
form = forms[0]
form.name = 'ruby'
form.submit
wait

# create a background job
new_job = form{|f| f.action == 'job'}
new_job.name = 'background'
new_job.submit
wait

# create two jobs
new_job = form{|f| f.action == 'job'}
new_job.name = 'job1'
new_job.submit
wait

new_job = form{|f| f.action == 'job'}
new_job.name = 'job2'
new_job.submit
wait

# Record time sessions for two separate jobs, one session for each.
form{|f| f.action == 'start'}.element{|e| e.value == 'job1'}.click
wait
sleep 3
form{|f| f.action == 'start'}.element{|e| e.value == 'job2'}.click
wait
sleep 3
form{|f| f.action == 'pause_or_stop_job'}.elements('quick_stop').click
wait
form{|f| f.action == 'pause_or_stop_day'}.elements('stop_day').click
wait

# Verify that two time records appear.
tables = $iec.document.getElementsByTagName('TABLE')
results_table = tables.item(tables.length - 1) # last table
table_rows = results_table.getElementsByTagName('TR')
if table_rows.length == 3 # two rows plus header
  puts 'PASS'
else
  puts 'FAIL'
end

# Display the time records
for row in table_rows
  for td in row.getElementsbyTagName('TD')
    puts td.innerHtml
  end
end
    
  


