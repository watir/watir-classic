# Suggested solution to Lab 4, Part 1, Start The Day w/ Test Methods. (watir)

require 'toolkit/watir'
require 'toolkit/testhook'

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
$ie = IE.new
$ie.goto('http://localhost:8080')
$ie.textField(:name, 'name').set('ruby')
$ie.form(:index, 1).submit

# create a background job
$ie.form(:action, 'job').textField(:name, 'name').set('background')
$ie.form(:action, 'job').submit

# start the day
$ie.button(:name, 'start_day').click

# verify that the status message appears
if $ie.pageContainsText("Job 'background' started")
  puts 'PASS - job started'
else
  puts "FAIL - job didn't start"
end

# verify that the job appears in the recent records table
require 'toolkit/timeclock-recent-records'
if get_results_table_array.job_name(1) == 'background' and
   get_results_table_array.status(1) == 'running'
then
  puts 'PASS - background job is running'
else
  puts 'FAIL - background job is not running'
end


