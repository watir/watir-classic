# Suggested solution to Lab 3, Part 1, Start The Day. (watir)

require 'watir'
require 'toolkit/testhook'

# make sure we have a new user
ensure_no_user_data 'ruby'

# login
$ie = Watir::IE.start('http://localhost:8080')
$ie.text_field(:name, 'name').set('ruby')
$ie.button(:value , 'Login').click

# create a background job
$ie.form(:action, 'job').text_field(:name, 'name').set('background')
$ie.button(:value , 'Create' ).click 

# start the day
$ie.button(:name, 'start_day').click
