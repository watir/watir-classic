# Suggested solution to Lab 3, Part 3: Job Switching. (watir)

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

# create two non-background jobs
$ie.form(:action, 'job').textField(:name, 'name').set('job1')
$ie.form(:action, 'job').submit
$ie.form(:action, 'job').textField(:name, 'name').set('job2')
$ie.form(:action, 'job').submit

# alternate between the two jobs
3.times do
  $ie.form(:action, 'start').button(:value, 'job1').click
  sleep 1
  $ie.form(:action, 'start').button(:value, 'job2').click
  sleep 1
end
