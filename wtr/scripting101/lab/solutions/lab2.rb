# Suggested solution to lab 2.

require 'toolkit'

# login
start_ie("http://localhost:8080")
form = get_forms[0]
form.name = "bret"
form.submit
@iec.wait

# create a new job
new_job = get_form_by_action("job")
new_job.name = "ruby article"
new_job.submit
@iec.wait

# start the new job
all_jobs = get_form_by_action("start")
get_element_by_value(all_jobs, "ruby article").click
@iec.wait

# stop the day
top_form = get_form_by_action("pause_or_stop_day")
top_form.elements("stop_day").click
@iec.wait

puts "COMPLETE"
