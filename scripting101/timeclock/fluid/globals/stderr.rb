puts "This is an example of redirecting $stderr to log-file."

def inspector(tag)
  puts "============="
  puts "#{tag}, $stderr = #{$stderr.inspect}"
end

inspector("Originally")
$stderr.puts "Originally, $stderr goes to standard output."

$saved_original = $stderr.dup
$stderr = File.open("log-file", "w")

inspector("After redirect")
$stderr.puts "After redirect, $stderr goes to log-file."

$save_for_close = $stderr
$stderr = $saved_original
$save_for_close.close

inspector("After restoration")
$stderr.puts "After restoration, $stderr goes to standard output."
