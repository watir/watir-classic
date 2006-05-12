# Suggested solution to Lab 5, Part 1, Start The Day w/ Assertions

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'
require 'test/unit/assertions'
include Test::Unit::Assertions

# make sure we have a new user
user_name = 'ruby'
ensure_no_user_data(user_name)

# login
ie = Watir::IE.start('http://localhost:8080')
ie.text_field(:name, 'name').set(user_name)
ie.button(:value , 'Login').click

# create a background job
ie.text_field(:name, 'name').set('background')
ie.button(:value , 'Create').click 

# start the day
ie.button(:name, 'start_day').click

# verify the status text
assert( ie.p(:id, 'last_results').text.include?( "Job 'background' started" ))
assert( ie.p(:id, 'running_job').text.include?( "Job 'background' is running." ))

# verify that the job appears in the recent records table
assert( ie.table(:id, 'recent_records')[2][1].text == 'background' )
assert( ie.table(:id, 'recent_records')[2][4].text == 'running' )

