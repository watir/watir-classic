require 'watir-classic'
require 'watir-classic/core'
require 'watir-classic/close_all'
require 'watir-classic/ie-process'

# these switches need to be deleted from ARGV to enable the Test::Unit
# functionality that grabs
# the remaining ARGV as a filter on what tests to run.
# Note: this means that watir-classic must be require'd BEFORE test/unit.
# (Alternatively, you could require test/unit first and then put the Watir::IE
# arguments after the '--'.)

# Make Internet Explorer invisible. -b stands for background
$HIDE_IE ||= ARGV.delete('-b')

# Run fast
$FAST_SPEED = ARGV.delete('-f')

# Eat the -s command line switch (deprecated)
ARGV.delete('-s')
