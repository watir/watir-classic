# Suggested solution to Lab 3, Part 2: Start, Stop and Pause. (watir)



$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'watir'
require '../toolkit/testhook'

include Watir

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

# create a non-background job
$ie.form(:action, 'job').textField(:name, 'name').set('foreground')
$ie.form(:action, 'job').submit

# start the job
$ie.form(:action, 'start').button(:value, 'foreground').click

# pause the job
$ie.button(:name, 'pause').click

# restart the job
$ie.button(:value, 'foreground').click

# stop the job
$ie.button(:name, 'quick_stop').click
