$: << File.dirname(__FILE__)
require 'testhook.rb'

for user in ARGV
  ensure_no_user_data(user)
  puts "Timeclock data for #{ user } deleted."
end
