#!/bin/sh
export RUBYLIB="../fluid:../ruby-trace"
export VW_TIMECLOCK_DATA_DIR="c:/temp/timeclock"
cd ../bin
ruby command-line $*
