# push all the buttons on the main timeclock page
require 'toolkit'

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

# start day
form{|f| f.action == 'start_day'}.elements('start_day').click
$iec.wait
assert_equal "Job 'background' is running.", get_status_message
assert_total_job_records 1
assert_job_record 1, 'background', '<B>running</B>'

# pause day
form{|f| f.action == 'pause_or_stop_day'}.elements('pause_day').click
$iec.wait
assert_equal "No job is recording time.", get_status_message
assert_job_record 1, 'background', 'paused'

# stop day
form{|f| f.action == 'pause_or_stop_day'}.elements('stop_day').click
$iec.wait
assert_equal 'No job is recording time.', get_status_message
assert_job_record 1, 'background', ''

# start day
form{|f| f.action == 'start_day'}.elements('start_day').click
$iec.wait

# refresh
form{|f| f.action == 'refresh'}.elements('refresh').click
$iec.wait
assert_equal "Job 'background' is running.", get_status_message
assert_job_record 1, 'background', '<B>running</B>'

# create job
form{|f| f.action == 'job'}.name = 'new job'
form{|f| f.action == 'job'}.submit
$iec.wait

# start job
form{|f| f.action == 'start'}.element{|e| e.value == 'new job'}.click
$iec.wait
assert_equal "Job 'new job' is running.", get_status_message
assert_job_record 1, 'new job', '<B>running</B>'

# pause job
form{|f| f.action == 'pause_or_stop_job'}.elements('pause').click
$iec.wait
assert_equal "Job 'background' is running.", get_status_message
assert_job_record 1, 'new job', 'paused'
assert_job_record 2, 'background', '<B>running</B>'

# stop job
form{|f| f.action == 'pause_or_stop_job'}.elements('quick_stop').click
$iec.wait
assert_equal "No job is recording time.", get_status_message
assert_job_record 1, 'new job', 'paused'
assert_job_record 2, 'background', ''

# restart job
forms[3].element{|e| e.value == 'new job'}.click
$iec.wait
assert_equal "Job 'new job' is running.", get_status_message
assert_job_record 1, 'new job', '<B>running</B>'



