#--
#  The 'watir' library loads the common watir code, common to all watir
# implementations. The 'watir/browser' library will autoload the actual
# implementations.

require 'watir/version'
require 'watir/waiter' # this will be removed in some future version
require 'watir/wait'
require 'watir/wait_helper'
require 'watir/element_extensions'
require 'watir/util'
require 'watir/exceptions'
require 'watir/matches'
require 'watir/browser'
