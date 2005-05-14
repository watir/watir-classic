# Suggested solution to Lab 4, Part 2: Start, Stop and Pause w/ Test Methods

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'

# define a function that we will use in the script below
def check_status(ie, expected)
    if ie.p(:id, 'last_results').text.include? expected
      puts "PASS - #{expected}"
    else
      puts "FAIL - expected: <#{expected}>, actual: <#{ie.p(:id, 'last_results').text}"
    end
end    

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
ie = Watir::IE.start('http://localhost:8080')
ie.text_field(:name, 'name').set('ruby')
ie.button(:value, 'Login').click

# create a background job
ie.text_field(:name, 'name').set('background')
ie.button(:value, 'Create').click 

# create a non-background job
ie.text_field(:name, 'name').set('foreground')
ie.button(:value, 'Create').click 

# start the job
ie.button(:value, 'foreground').click
check_status ie, "Job 'foreground' started"

# pause the job
ie.button(:name, 'pause').click
check_status ie, "Paused 'foreground'"

# restart the job
ie.button(:value, 'foreground').click
check_status ie, "Job 'foreground' resumed"

# stop the job
ie.button(:name, 'quick_stop').click
check_status ie, "Stopped 'foreground'"