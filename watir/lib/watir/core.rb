# these require statements are needed for Watir
# to work with minimum functionality
require 'timeout'
require 'watir/win32ole'

# these are required already in commonwatir, but not when using click_no_wait!
require 'watir/util'
require 'watir/exceptions'
require 'watir/matches'
require 'watir/wait'
require 'watir/wait_helper'
require 'watir/element_extensions'

require 'logger'
require 'watir/logger'
require 'watir/container'
require 'watir/xpath_locator'
require 'watir/locator'
require 'watir/page-container'
require 'watir/ie-class'
require 'watir/drag_and_drop_helper'
require 'watir/element'
require 'watir/element_collection'
require 'watir/form'
require 'watir/frame'
require 'watir/input_elements'
require 'watir/non_control_elements'
require 'watir/table'
require 'watir/image'
require 'watir/link'
require 'watir/window'
require 'watir/cookies'

require 'watir/win32'
require 'watir/modal_dialog'

require 'watir/module'

require 'rautomation'
require 'watir/dialogs/file_field'
require 'watir/dialogs/javascript'

require 'watir/supported_elements'
