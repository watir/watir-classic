require 'toolkit'

# assume we have a new user. (delete user-file and restart server if necessary.)

# login
start_ie("http://localhost:8080")
form = forms[0]
form.name = "ruby"
form.submit
wait

# create a background job
new_job = get_form_by_action("job")
new_job.name = "background"
new_job.submit
wait

# create two non-background jobs
new_job = get_form_by_action("job")
new_job.name = "job1"
new_job.submit
wait

new_job = get_form_by_action("job")
new_job.name = "job2"
new_job.submit
wait

# alternate between the two jobs
3.times do
  button_click_by_value("start","job1")
  sleep 2
  button_click_by_value("start","job2")
  sleep 2
end

