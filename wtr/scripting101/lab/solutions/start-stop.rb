require 'toolkit'

# login
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

# create a non-background job
new_job = get_form_by_action("job")
new_job.name = "foreground"
new_job.submit
@iec.wait

# start the job
all_jobs = get_form_by_action("start")
get_element_by_value(all_jobs, "foreground").click
@iec.wait

# pause the job
pause_or_stop_form = get_form_by_action("pause_or_stop_job")
pause_or_stop_form.elements("pause").click
@iec.wait

# restart the job
for form in @iec.document.forms
  if form.action == "start"
    paused_form = IEDomFormWrapper.new(form)
  end
end
get_element_by_value(paused_form, "foreground").click
@iec.wait

# stop the job
pause_or_stop_form = get_form_by_action("pause_or_stop_job")
pause_or_stop_form.elements("quick_stop").click
@iec.wait





