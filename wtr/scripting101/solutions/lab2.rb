# Suggested solution to lab 2 using watir.

require 'toolkit/watir'

# 1. Login using existing account
$ie = IE.new
$ie.goto('http://localhost:8080')
$ie.textField(:name, 'name').set('paul')
$ie.form(:index, 1).submit

# 2. Create a new job
$ie.form(:action, 'job').textField(:name, 'name').set('ruby article')
$ie.form(:action, 'job').submit

# 3. Start the new job
$ie.button(:value, 'ruby article').click

# 4. Stop the day
$ie.button(:name, 'stop_day').click

puts "COMPLETE"
