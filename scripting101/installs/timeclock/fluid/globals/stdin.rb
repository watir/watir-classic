# This demonstrates that caching prevents successful redirection of $stdin. 
# Run like this:
# ruby stdin.rb < in
# By choosing which line to uncomment, you can try variants. None of them
# work (Ruby 1.6).

stash = $stdin.dup
puts(gets)
$stdin.reopen("alternate-in")
# $stdin = File.open("alternate-in")
puts(gets)
$stdin.reopen(STDIN)
# $stdin.reopen(stash)
# $stdin = stash
# $stdin = STDIN
puts(gets)
exit 0

