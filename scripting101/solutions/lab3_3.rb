# Suggested solution to Lab 3, Part 3: Job Switching

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
ie = Watir::IE.start('http://localhost:8080')
ie.text_field(:name, 'name').set('ruby')
ie.button(:value , 'Login').click

# create a background job
ie.text_field(:name, 'name').set('background')
ie.button(:value , 'Create').click 

# create two non-background jobs
ie.text_field(:name, 'name').set('job1')
ie.button(:value , 'Create').click 
ie.text_field(:name, 'name').set('job2')
ie.button(:value , 'Create').click 

# alternate between the two jobs
3.times do
  ie.button(:value, 'job1').click
  sleep 1
  ie.button(:value, 'job2').click
  sleep 1
end
