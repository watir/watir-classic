require 'fluid.rb'

# This test must be run with $defout bound to a file. It is intended to
# be run from within test-fluid.rb.

# Note that these variables must be kept in sync with the locals in
# test_defout in test-fluid.rb.
outer_text = %w{outer-line-1 outer-line-2}
middle_file = "defout_middle.out"
middle_text = %w{middle-line-1 middle-line-2 middle-line-3}
inner_file = "defout_inner.out"
inner_text = %w{inner-line-1 inner-line-2 inner-line-3 inner-line-4}
assign_file = "defout_assign.out"
assign_text = %w{assign-line-1 assign-line-2 assign-line-3}


puts(outer_text[0])

middle_stream = nil # to check if stream is closed
Fluid.let(["$defout", File.open(middle_file, "w"), :close]) {
  middle_stream = $defout
  puts(middle_text[0])
  middle_stream.puts(middle_text[1])

  inner_stream = nil   # to check that stream is NOT closed.
  Fluid.let([:$>, File.open(inner_file, "w")]) {
    inner_stream = $defout
    puts(inner_text[0])
    inner_stream.puts(inner_text[1])
    puts(inner_text[2])
    # Note that exiting this block, which binds $>, will undo an
    # assignment to $defout.
    $defout = File.open(assign_file, "w")
    raise "$> was not also assigned" if $> != $defout
    puts(assign_text[0])
    $defout.puts(assign_text[1])
    $>.puts(assign_text[2])
    $defout.close
  }
  raise "$defout was not rebound" if $defout != middle_stream
  raise "$> was not rebound" if $> != middle_stream
  inner_stream.puts(inner_text[3]) # still available.
  puts(middle_text[2])
}

begin
  middle_stream.puts("Never seen")
rescue IOError
  puts(outer_text[1])
else
  puts "EXCEPTION NOT GENERATED - MIDDLE_STREAM NOT CLOSED"
end
