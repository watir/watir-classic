# Suggested solution to Lab 3, Part 3: Job Switching. (watir)


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
$ie.textField(:name, 'name').set(user_name)
$ie.button(:value , 'Login').click

# create a background job
$ie.form(:action, 'job').textField(:name, 'name').set('background')
$ie.button(:value , /create/i ).click 

# create two non-background jobs
$ie.form(:action, 'job').textField(:name, 'name').set('job1')
$ie.button(:value , /create/i ).click 
$ie.form(:action, 'job').textField(:name, 'name').set('job2')
$ie.button(:value , /create/i ).click 

# alternate between the two jobs
3.times do
  $ie.form(:action, 'start').button(:value, 'job1').click
  sleep 1
  $ie.form(:action, 'start').button(:value, 'job2').click
  sleep 1
end
