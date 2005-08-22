# Suggested solution to Lab 3, Part 2: Start, Stop and Pause. (watir)


require 'watir'
require 'toolkit/testhook'

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
$ie = Watir::IE.start('http://localhost:8080')
$ie.textField(:name, 'name').set('ruby')
# here we use a regular expression to locate the create button
$ie.button(:value , 'Login').click

# create a background job
$ie.form(:action, 'job').textField(:name, 'name').set('background')
# here we use a regular expression to locate the create button
$ie.button(:value , 'Create').click 

# create a non-background job
$ie.form(:action, 'job').textField(:name, 'name').set('foreground')
# here we use a regular expression to locate the create button
$ie.button(:value , 'Create').click 

# start the job
$ie.form(:action, 'start').button(:value, 'foreground').click

# pause the job
$ie.button(:name, 'pause').click

# restart the job
$ie.button(:value, 'foreground').click

# stop the job
$ie.button(:name, 'quick_stop').click
