require 'toolkit'

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

# create a non-background job
new_job = form{|f| f.action == 'job'}
new_job.name = "foreground"
new_job.submit
wait

# start the job
all_jobs = form{|f| f.action == 'start'}
all_jobs.element{|e| e.value == 'foreground'}.click
wait

# pause the job
pause_or_stop_form = form{|f| f.action == 'pause_or_stop_job'}
pause_or_stop_form.elements("pause").click
wait

# restart the job
for form in $iec.document.forms
  if form.action == "start"
    paused_form = IEDomFormWrapper.new(form)
  end
end
paused_form.element{|e| e.value == 'foreground'}.click
wait

# stop the job
pause_or_stop_form = form{|f| f.action == 'pause_or_stop_job'}
pause_or_stop_form.elements("quick_stop").click
wait





