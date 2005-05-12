# Suggested solution to Lab 4, Part 1, Start The Day w/ Test Methods

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'

# make sure we have a new user
user_name = 'ruby'
ensure_no_user_data(user_name)

# login
ie = Watir::IE.start('http://localhost:8080')
ie.text_field(:name, 'name').set(user_name)
ie.button(:value , 'Login').click

# create a background job
ie.text_field(:name, 'name').set('background')
ie.button(:value , 'Create').click 

# start the day
ie.button(:name, 'start_day').click

# verify the status text
if ie.p(:id, 'last_results').text.include? "Job 'background' started"
  puts 'PASS - job started'
else
  puts "FAIL - job didn't start"
end
if ie.p(:id, 'running_job').text.include? "Job 'background' is running."
  puts 'PASS - job running'
else
  puts "FAIL - job not running"
end

# verify that the job appears in the recent records table
if ie.table(:id, 'recent_records')[2][1].text == 'background' and
   ie.table(:id, 'recent_records')[2][4].text == 'running'
then
  puts 'PASS - background job is running'
else
  puts 'FAIL - background job is not running'
end


