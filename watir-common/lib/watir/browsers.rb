# watir/browsers
# Define browsers supported by Watir

module Watir; autoload :IE, 'watir/ie'; end
Watir::Browser.support 'ie', 'Watir::IE', [:speed, :visible]

module FireWatir; autoload :Firefox, 'firewatir'; end
Watir::Browser.support 'firefox', 'FireWatir::Firefox'


