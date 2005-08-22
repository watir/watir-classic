# Suggested solution to lab 2 using watir.

require 'watir'

# 1. Login using existing account
$ie = Watir::IE.new
$ie.goto('http://localhost:8080')
$ie.text_field(:name, 'name').set('paul')
$ie.button(:value, 'Login').click

# 2. Create a new job
$ie.form(:action, 'job').text_field(:name, 'name').set('ruby article')
$ie.button(:value , 'Create').click 

# 3. Start the new job
$ie.button(:value, 'ruby article').click

# 4. Stop the day
$ie.button(:name, 'stop_day').click

puts "COMPLETE"
