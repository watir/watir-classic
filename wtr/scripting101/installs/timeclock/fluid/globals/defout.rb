puts "This is an example of redirecting $defout to log-file."

def inspector(tag)
  puts "============="
  puts "#{tag}, $stdout = #{$stdout.inspect}, $defout=#{$defout.inspect}, $> = #{$>.inspect}"
end

inspector("Originally")
$stdout.puts "A message to $stdout - shows ordering preserved."
$defout.puts "A message to $defout - shows ordering preserved."
$stdout.puts "Another message to $stdout - shows ordering preserved."
$defout.puts "Another message to $defout - shows ordering preserved."

$saved_original = $defout
$defout = File.open("log-file", "w")

inspector("After redirect")
$stdout.puts "After redirect, $stdout goes to standard output."
$defout.puts "After redirect, $defout goes to log-file."
$>.puts "After redirect, $> goes to log-file."
p "Note that 'p' is redirected as well."

$defout.close
$defout = $saved_original

inspector("After restoration")
$stdout.puts "After restoration, $stdout goes to standard output."
$defout.puts "After restoration, $defout goes to standard output."
$>.puts "After restoration, $> goes to standard output."

$stdout.puts "Another message to $stdout - shows ordering preserved."
$defout.puts "Another message to $defout - shows ordering preserved."
