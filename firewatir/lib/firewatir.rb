$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'socket'
require 'watir'
require 'firewatir/exceptions'
require 'firewatir/jssh_socket'
require 'firewatir/container'
require "firewatir/element"
require "firewatir/document"

require "firewatir/elements/form"
require "firewatir/elements/frame"
require "firewatir/elements/non_control_element"
require "firewatir/elements/non_control_elements"
require "firewatir/elements/table"
require "firewatir/elements/table_row"
require "firewatir/elements/table_cell"
require "firewatir/elements/image"
require "firewatir/elements/link"
require "firewatir/elements/input_element"
require "firewatir/elements/select_list"
require "firewatir/elements/option"
require "firewatir/elements/button"
require "firewatir/elements/text_field"
require "firewatir/elements/hidden"
require "firewatir/elements/file_field"
require "firewatir/elements/radio_check_common"
require "firewatir/element_collections"

require 'firewatir/firefox'

#--
# this only has an effect if firewatir is required before anyone invokes 
# Browser.new. Thus it has no effect when Browser.new itself autoloads this library.
#++
Watir::Browser.default = 'firefox'
