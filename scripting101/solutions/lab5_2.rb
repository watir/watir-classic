# Suggested solution to Lab 5, Part 2: Start, Stop and Pause w/ Assertions

# This line helps Ruby find the toolkit libraries
$LOAD_PATH << '..' if $0 == __FILE__

require 'watir'
require 'toolkit/testhook'
require 'test/unit/assertions'
include Test::Unit::Assertions

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
assert_match( /^Job 'foreground' started/, ie.p(:id, 'last_results').text )

# pause the job
ie.button(:name, 'pause').click
assert_match( /^Paused 'foreground'/, ie.p(:id, 'last_results').text )

# restart the job
ie.button(:value, 'foreground').click
assert_match( /^Job 'foreground' resumed/, ie.p(:id, 'last_results').text )

# stop the job
ie.button(:name, 'quick_stop').click
assert_match( /^Stopped 'foreground'/, ie.p(:id, 'last_results').text )