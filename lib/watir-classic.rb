require 'timeout'
require 'multi_json'      
require 'rautomation'

require 'watir-classic/version'
require 'watir-classic/win32ole'
require 'watir-classic/util'
require 'watir-classic/exceptions'
require 'watir-classic/matches'
require 'watir-classic/wait'
require 'watir-classic/wait_helper'
require 'watir-classic/element_extensions'
require 'watir-classic/container'
require 'watir-classic/xpath_locator'
require 'watir-classic/locator'
require 'watir-classic/page-container'
require 'watir-classic/browser_process'
require 'watir-classic/screenshot'
require 'watir-classic/browser'
require 'watir-classic/drag_and_drop_helper'
require 'watir-classic/element'
require 'watir-classic/element_collection'
require 'watir-classic/form'
require 'watir-classic/frame'
require 'watir-classic/input_elements'
require 'watir-classic/non_control_elements'
require 'watir-classic/table'
require 'watir-classic/image'
require 'watir-classic/link'
require 'watir-classic/window'
require 'watir-classic/cookies'
require 'watir-classic/win32'
require 'watir-classic/modal_dialog'
require 'watir-classic/module'
require 'watir-classic/dialogs/file_field'
require 'watir-classic/dialogs/alert'
require 'watir-classic/supported_elements'

module Watir
  autoload :IE, File.expand_path("watir-classic/ie_deprecated", File.dirname(__FILE__))

  class << self
    def default_timeout
      @default_timeout ||= 30
    end

    #
    # Default wait time for wait methods.
    #

    def default_timeout=(value)
      @default_timeout = value
    end
  end
end
