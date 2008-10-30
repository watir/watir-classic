# watir/browsers
# Define browsers supported by Watir

module Watir; autoload :IE, 'watir/ie'; end
Watir::Browser.support 'ie', 'Watir::IE', [:speed, :visible]

module FireWatir; autoload :Firefox, 'firewatir'; end
Watir::Browser.support 'firefox', 'FireWatir::Firefox'

module Watir; autoload :Safari, 'safariwatir'; end
Watir::Browser.support 'safari', 'Watir::Safari'


