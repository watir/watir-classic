# This shows that if you redirect $stdout, when you put it back, 
# synchronization between $stdout and $defout is lost.

puts "This is an example of redirecting $stdout to log-file."

def inspector(tag)
  puts "============="
  puts "#{tag}, $stdout = #{$stdout.inspect}, $defout=#{$defout.inspect}, $> = #{$>.inspect}"
end

inspector("Originally")
$stdout.puts "A message to $stdout - shows ordering preserved."
$defout.puts "A message to $defout - shows ordering preserved."
$stdout.puts "Another message to $stdout - shows ordering preserved."
$defout.puts "Another message to $defout - shows ordering preserved."

$saved_original = $stdout.dup
$stdout = File.open("log-file", "w")

inspector("After redirect")
$stdout.puts "After redirect, $stdout goes to log-file."
$defout.puts "After redirect, $defout goes to log-file."
$>.puts "After redirect, $> goes to log-file."
p "Note that 'p' is redirected as well."

$save_for_close = $stdout
$stdout = $saved_original
$save_for_close.close

inspector("After restoration")
$stdout.puts "After restoration, $stdout goes to standard output."
$defout.puts "After restoration, $defout goes to standard output."
$>.puts "After restoration, $> goes to standard output."

$stdout.puts "Another message to $stdout - shows ordering no longer preserved."
$defout.puts "Another message to $defout - shows ordering no longer preserved."
