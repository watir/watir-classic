puts "This is an example of redirecting $stdin to log-file."

def inspector(tag)
  puts "============="
  puts "#{tag}, $stdin = #{$stdin.inspect}, STDIN=#{STDIN}"
end

inspector("Originally")
puts(gets)

$saved_original = $stdin   # DUP does NOT work
$stdin = File.open("alternate-in", "r")

inspector("After redirect")
puts(gets)
puts(readline)

$save_for_close = $stdin
$save_for_close.close
$stdin = $saved_original

inspector("After restoration")
puts(gets)

