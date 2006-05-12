require 'watir'
require 'watir/cookiemanager'
include Watir
include CookieManager

puts WatirHelper.getSpecialFolderLocation(WatirHelper::COOKIES)
WatirHelper.deleteSpecialFolderContents(WatirHelper::COOKIES)
