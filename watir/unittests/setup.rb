logger = WatirLogger.new('test.txt' ,5, 65535 * 2)
$ie = IE.new(logger)
$myDir = File.expand_path(File.dirname(__FILE__))
