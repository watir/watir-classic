# Suggested solution to lab 2 using watir.

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'watir'
require 'toolkit/testhook'

include Watir

user_name = 'paul'

# make sure we have a new user
ensure_no_user_data( user_name )

# 1. Login using existing account
$ie = IE.new
$ie.goto('http://localhost:8080')
$ie.textField(:name, 'name').set(user_name)
$ie.button(:value , 'Login').click


# if there is no submit button available on a form, the form can be submitted like this:
#$ie.form(:index, 1).submit

# 2. Create a new job
$ie.form(:action, 'job').textField(:name, 'name').set('ruby article')

# here we use a regular expression to locate the create button
$ie.button(:value , /create/i ).click 

# 3. Start the new job
$ie.button(:value, 'ruby article').click

# 4. Stop the day
$ie.button(:name, 'stop_day').click

puts "COMPLETE"
