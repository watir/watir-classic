TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR
Dir.chdir TOPDIR
(Dir["unittests/*_test.rb"] - 
  (["unittests/popups_test.rb"] + ["unittests/filefield_test.rb"])).each {|x| require x}
