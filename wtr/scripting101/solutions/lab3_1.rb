# Suggested solution to Lab 3, Part 1, Start The Day. (watir)

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
# here we use a regular expression to locate the create button
$ie.button(:value , /create/i ).click 

# start the day
$ie.button(:name, 'start_day').click
