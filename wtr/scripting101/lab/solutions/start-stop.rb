# Suggested solution to Lab 3, Part 2: Start, Stop and Pause.
require 'toolkit'

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
start_ie('http://localhost:8080')
form = forms[0]
form.name = 'ruby'
form.submit
wait

# create a background job
new_job = form{|f| f.action == 'job'}
new_job.name = 'background'
new_job.submit
wait

# create a non-background job
new_job = form{|f| f.action == 'job'}
new_job.name = 'foreground'
new_job.submit
wait

# start the job
all_jobs = form{|f| f.action == 'start'}
all_jobs.element{|e| e.value == 'foreground'}.click
wait

# pause the job
pause_or_stop_form = form{|f| f.action == 'pause_or_stop_job'}
pause_or_stop_form.elements('pause').click
wait

# restart the job
paused_form = form{|f| f.action == 'start'}
paused_form.element{|e| e.value == 'foreground'}.click
wait

# stop the job
pause_or_stop_form = form{|f| f.action == 'pause_or_stop_job'}
pause_or_stop_form.elements('quick_stop').click
wait





