system "echo redirected > redirected"
$stdin = File.open("redirected", 'r')
puts(gets)
