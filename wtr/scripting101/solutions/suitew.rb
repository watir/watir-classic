require 'test/unit'

$: << File.join( File.dirname( __FILE__ ), '..' )
require 'toolkit/iostring'
require 'toolkit/testhook'


class Lab2 < Test::Unit::TestCase
  def setup
    ensure_no_user_data 'paul' 
    # Note: test just happens to work whether this is a new or existing user. 
    # It is spec'ed to only work with an existing user...
    @mockout = IOString.new ""
  end
  def test_lab2
    $stdout = @mockout
    load 'lab2w.rb'
    $stdout = STDOUT
    assert_match /COMPLETE\n$/, @mockout

    # verify one job was created and it is no longer running.
    # (presumes ie isn't closed)
#    assert_total_job_records 1
#    assert_job_record 1, 'ruby article', ''
  end
  def teardown
    $stdout = STDOUT
#    $ie.close if $ie
  end
end
