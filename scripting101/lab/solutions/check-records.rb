# Suggested solution to lab exercise 3-4
require 'toolkit'

# Start with a user that has no time records. 
start_ie("http://localhost:8080")
form = get_forms[0]
form.name = "ruby"
form.submit
@iec.wait

# create a background job
new_job = get_form_by_action("job")
new_job.name = "background"
new_job.submit
@iec.wait

# create two jobs
new_job = get_form_by_action("job")
new_job.name = "job1"
new_job.submit
@iec.wait

new_job = get_form_by_action("job")
new_job.name = "job2"
new_job.submit
@iec.wait

# Record time sessions for two separate jobs, one session for each.
button_click_by_value("start","job1")
sleep 3
button_click_by_value("start","job2")
sleep 3
button_click_by_name("pause_or_stop_job","quick_stop")
button_click_by_name("pause_or_stop_day","stop_day")

# Verify that two time records appear.
tables = @iec.document.getElementsByTagName("TABLE")
results_table = tables.item(tables.length - 1) # last table
table_rows = results_table.getElementsByTagName("TR")
if table_rows.length == 3 # two rows plus header
  puts "PASS"
else
  puts "FAIL"
end

# Display the time records
for row in table_rows
  for td in row.getElementsbyTagName("TD")
    puts td.innerHtml
  end
end
    
  


