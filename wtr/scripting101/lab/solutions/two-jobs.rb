require 'toolkit'

# assume we have a new user. (delete user-file and restart server if necessary.)

# login
start_ie("http://localhost:8080")
form = forms[0]
form.name = "ruby"
form.submit
wait

# create a background job
new_job = form{|f| f.action == 'job'}
new_job.name = "background"
new_job.submit
wait

# create two non-background jobs
new_job = form{|f| f.action == 'job'}
new_job.name = "job1"
new_job.submit
wait

new_job = form{|f| f.action == 'job'}
new_job.name = "job2"
new_job.submit
wait

# alternate between the two jobs
3.times do
  form{|f| f.action == 'start'}.element{|e| e.value == 'job1'}.click
  wait
  sleep 2
  form{|f| f.action == 'start'}.element{|e| e.value == 'job2'}.click
  wait
  sleep 2
end

