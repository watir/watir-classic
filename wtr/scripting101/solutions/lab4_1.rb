# Suggested solution to Lab 4, Part 1, Start The Day w/ Test Methods. (watir)


$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'watir'
require 'toolkit/testhook'

include Watir



user_name = 'ruby'

# make sure we have a new user
ensure_no_user_data( user_name )

# login
$ie = IE.new
$ie.goto('http://localhost:8080')
$ie.textField(:name, 'name').set( user_name )
$ie.button(:value , 'Login').click

# create a background job
$ie.form(:action, 'job').textField(:name, 'name').set('background')
$ie.button(:value , /create/i ).click 

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
if get_results_table_array($ie.ie.document).job_name(1) == 'background' and
   get_results_table_array($ie.ie.document).status(1) == 'running'
then
  puts 'PASS - background job is running'
else
  puts 'FAIL - background job is not running'
end


