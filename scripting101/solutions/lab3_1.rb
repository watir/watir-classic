# Suggested solution to Lab 3, Part 1, Start The Day. (watir)

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

# start the day
$ie.button(:name, 'start_day').click
