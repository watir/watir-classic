# Suggested solution to Lab 3, Part 2: Start, Stop and Pause

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'

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

# pause the job
ie.button(:name, 'pause').click

# restart the job
ie.button(:value, 'foreground').click

# stop the job
ie.button(:name, 'quick_stop').click
