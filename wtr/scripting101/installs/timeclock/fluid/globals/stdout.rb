# This shows that if you redirect $stdout, when you put it back, 
# synchronization between $stdout and $defout is lost.

$stdout.puts "Message 1 ($stdout)"
$defout.puts "Message 2 ($defout)"
$stdout.puts "Message 3 ($stdout)"
$defout.puts "Message 4 ($defout)"

$saved_original = $stdout.dup
$stdout = File.open("log-file", "w")

$stdout.puts "After redirect, $stdout goes to log-file."
$defout.puts "After redirect, $defout goes to log-file."

$save_for_close = $stdout
$stdout = $saved_original
$save_for_close.close

$stdout.puts "Message 5 ($stdout)"
$defout.puts "Message 6 ($defout)"
$stdout.puts "Message 7 ($stdout)"
$defout.puts "Message 8 ($defout)"
