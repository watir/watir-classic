module Watir
  version_file = File.dirname(__FILE__) + '/../../VERSION'
  VERSION = File.exists?(version_file) ? File.read(version_file).strip : "0.0.0"
end