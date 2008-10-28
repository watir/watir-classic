# watir/browsers
# Define browsers supported by Watir

module Watir; autoload :IE, 'watir'; end
Watir::Browser.support 'ie', 'Watir::IE'

module FireWatir; autoload :Firefox, 'firewatir'; end
Watir::Browser.support 'firefox', 'FireWatir::Firefox'


