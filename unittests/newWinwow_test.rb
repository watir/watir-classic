$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'
require 'unittests/setup'



$ie.goto($htmlRoot + 'links1.html')
$ie.link(:index ,5).click
ie2 = $ie.newWindow
ie2.link(:index ,5).click

