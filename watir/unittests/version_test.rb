
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Version < Test::Unit::TestCase

  def test_full_version
    assert !Watir::IE.version.nil?
  end

  def test_version_part
    assert Watir::IE.version_parts[0] =~ /^\d+$/
  end

end