require 'fluid.rb'

# This test must be run with $stderr bound to a file. It is intended to
# be run from within test-fluid.rb.

# Note that these variables must be kept in sync with the locals in
# test_stderr in test-fluid.rb.
outer_text = %w{outer-line-1 outer-line-2 outer-line-3}
middle_file = "stderr_middle.out"
middle_text = %w{middle-line-1 middle-line-2}
inner_file = "stderr_inner.out"
inner_text = %w{inner-line-1}

# These are used to check that the stream is truly closed.
middle_stream = nil
inner_stream = nil

$stderr.puts(outer_text[0])

Fluid.let(["$stderr", File.open(middle_file, "w"), :close]) {
  middle_stream = $stderr
  $stderr.puts(middle_text[0])

  Fluid.let([:$stderr, File.open(inner_file, "w"), :close]) {
    inner_stream = $stderr
    $stderr.puts(inner_text[0])
  }
  $stderr.puts(middle_text[1])
}

begin
  middle_stream.puts("Never seen")
rescue IOError
  $stderr.puts(outer_text[1])
else
  puts "EXCEPTION NOT GENERATED - MIDDLE_STREAM NOT CLOSED"
end

begin
  inner_stream.puts("Never seen")
rescue IOError
  $stderr.puts(outer_text[2])
else
  puts "EXCEPTION NOT GENERATED - INNER_STREAM NOT CLOSED"
end

