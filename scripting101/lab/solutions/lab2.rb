# Suggested solution to lab 2.

# Note: This lab uses IRB, where the 'waits' aren't really necessary

require 'toolkit'

# 1. Login using existing account
start_ie # may have to specify URL
forms[0].name = "bret"
forms[0].submit
wait

# 2. Create a new job
new_job = form{|f| f.action == 'job'}
new_job.name = "ruby article"
new_job.submit
wait

# 3. Start the new job
form{|f| f.action == 'start'}.element{|e| e.value == 'ruby article'}.click
wait

# 4. Stop the day
top_form = form{|f| f.action == 'pause_or_stop_day'}
top_form.elements('stop_day').click
wait

puts "COMPLETE"
