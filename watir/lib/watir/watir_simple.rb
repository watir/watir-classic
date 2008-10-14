=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2004-2005, Atomic Object LLC
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. Neither the name "Atomic Object LLC" nor the names of contributors to
  this software may be used to endorse or promote products derived from this
  software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  --------------------------------------------------------------------------
  (based on BSD Open Source License)
=end

require 'test/unit/assertions'
require 'watir'

module Watir
# = Description
# Watir::Simple is a simple wrapper around the Watir module.  It provides a
# similar set of operations while simplifying them and removing as much syntax
# and test-framework context code as possible.
# The goal is to allow toolsmiths to write domain-language frameworks on top of
# Watir, using Watir::Simple as an easier, lightweight interface to the power
# of Watir.
#
# = Note
# Most action methods in Watir::Simple will automatically wait for the browser
# not to be busy before and after they perform the specified action.
#
# revision: $Revision$
  module Simple

  # Open up a browser and point it at a certain URL.
	def new_browser_at(url)
		@@browser = IE.new
		@@browser.typingspeed = 0
		@@browser.goto url
	end


  # Tell the browser to load a particular URL.
	def navigate_to(url)
		@@browser.goto url
	end


  # Much like click_link_with_url but navigates to link instead of clicking it,
  # thereby not invoking OnClick for links.
  def navigate_to_link_with_url(url)
    # FIXME: this should be moved into Watir!
    wait_before_and_after do
      doc = @@browser.getDocument
      links = doc.links
      link = nil
      links.each do |n|
        match = false
        case url
        when Regexp
          match = (n.invoke("href") =~ url)
        when String
          match = (n.invoke("href") == url)
        end
        if match
          link = n
          break
        end
      end
      raise "Couldn't find link with url #{url}" unless link
      @@browser.goto link
    end
  end

  # Much like click_link_with_id but navigates to link instead of clicking it,
  # thereby not invoking OnClick for links.
  def navigate_to_link_with_id(id)
    # FIXME: this should be moved into Watir!
    wait_before_and_after do
      doc = @@browser.getDocument
      links = doc.links
      link = nil
      links.each do |n|
        match = false
        case id
        when Regexp
          match = (n.invoke("id") =~ id)
        when String
          match = (n.invoke("id") == id)
        end
        if match
          link = n
          break
        end
      end
      raise "Couldn't find link with id #{id}" unless link
      @@browser.goto link
    end
  end

  # Tell the browser to click on the first link with the specified URL.
  # This takes the address of the link instead of the text displayed.
  # * url - can be a string to match exactly, or a regular expression.
  #
  # Example:
  #   click_link_with_url "http://google.com"
  # or:
  #   click_link_with_url /goo*/
	def click_link_with_url(url)
    wait_before_and_after { @@browser.link(:url, url).click }
	end


  # Tell the browser to click on the first link with the specified id attribute
  # (the preferred method.)
	def click_link_with_id(id)
    wait_before_and_after { @@browser.link(:id, id).click }
	end


  # Tell the browser to click on the first link with the specified name attribute
	def click_link_with_name(name)
    wait_before_and_after { @@browser.link(:name, name).click }
	end


  # Tell the browser to click on the specified link as determined by the
  # sequential ordering of links on the document.
	def click_link_with_index(index)
    wait_before_and_after { @@browser.link(:index, index).click }
	end


  # Tell the browser to click on the first link with the specified text in the
  # link body.
	def click_link_with_text(text)
    wait_before_and_after { @@browser.link(:text, text).click }
	end


  # Set the text of the field with a given name  (the preferred method.)
  # This only types characters into the field and does not submit the form.
	def enter_text_into_field_with_name(name, text)
    wait_before_and_after { @@browser.textField(:name, name).set(text) }
	end


  # Set the text of the field with a given id attribute (the preferred method.)
  # This only types characters into the field and does not submit the form.
	def enter_text_into_field_with_id(id, text)
    wait_before_and_after { @@browser.textField(:id, id).set(text) }
	end


  # Set the text of the indexed field.  This only types characters
  # into the field and does not submit the form.
	def enter_text_into_field_with_index(index, text)
    wait_before_and_after { @@browser.textField(:index, index).set(text) }
	end


  # Select an item from a selectbox (a.k.a "combo box", or "pulldown")
  # The selectbox is chose by matching its name attribute.
  # The item is selected based on the text content of <OPTION> tags.
	def select_from_combobox_with_name(name, text)
		wait_before_and_after {	@@browser.selectBox(:name, name).select(text) }
	end


  # Select an item from a selectbox (a.k.a "combo box", or "pulldown")
  # The selectbox is chose by matching its id attribute.
  # The item is selected based on the text content of <OPTION> tags.
  def select_from_combobox_with_id(id, text)
		wait_before_and_after {	@@browser.selectBox(:id, id).select(text) }
	end


  # Select an item from a selectbox (a.k.a "combo box", or "pulldown")
  # The selectbox is chose by matching its order of appearance in the
  # document.
  # The item is selected based on the text content of <OPTION> tags.
  def select_from_combobox_with_index(index, text)
		wait_before_and_after {	@@browser.selectBox(:index, index).select(text) }
	end


  # Select an item (+value+) from the radio button collection with +name+.
	def select_radio_button_with_name(name, value)
		wait_before_and_after {	@@browser.radio(:name, name, value).click }
	end


  # Select an item (+value+) from the +index+'th radio button collection.
	def select_radio_button_with_name(index, value)
		wait_before_and_after {	@@browser.radio(:index, index, value).click }
	end


  # Select an item (+value+) from the radio button collection with a matching
  # +id+ attribute.
	def select_radio_button_with_id(id, value)
    wait_before_and_after {	@@browser.radio(:id, id, value).click }
	end


  # Tell the browser to click on a form button with +name+.
  def click_button_with_name(name)
    wait_before_and_after {	@@browser.button(:name, name).click }
	end


  # Tell the browser to click on a form button with the specified id attribute.
	def click_button_with_id(id)
		wait_before_and_after {	@@browser.button(:id, id).click }
	end


  # Tell the browser to click on a form button with the specified value attribute.
	def click_button_with_value(value)
		wait_before_and_after {	@@browser.button(:value, value).click }
	end


  # Tell the browser to click on a form button with the specified caption text.
	def click_button_with_caption(caption)
		wait_before_and_after {	@@browser.button(:caption, caption).click }
	end


  # Tell the browser to click on the +index+'th form button on the page.
	def click_button_with_index(index)
		wait_before_and_after {	@@browser.button(:index, index).click }
	end


  # Make a Test::Unit assertion that the given +text+ does not appear in the text
  # body.
  #
  # * mesg - An assertion-failed message.
	def assert_text_not_in_body(text,mesg=nil)
		if mesg.nil? then
			assert_false( @@browser.pageContainsText(text), "found in body: [#{text}]")
		else
			assert_false( @@browser.pageContainsText(text), mesg)
		end
	end


  # Make a Test::Unit assertion that the given +text+ appears in the text
  # body.
  #
  # * text - +String+ or +RegExp+ - The text or regular expression to search for.
  # * mesg - +String+             - An optional assertion-failed message.
	def assert_text_in_body(text,mesg=nil)
		if mesg.nil? then
			assert(@@browser.pageContainsText(text), "couldn't find in body: [#{text}]")
		else
			assert(@@browser.pageContainsText(text), mesg)
		end
	end


  # This method returns true|false if the text/reg exp supplied is in a the text field "name".
  #
  # * name - +String+            - Name of field to examine.
  # * text - +String+ or +RegExp+ - The text or regular expression to search for.
  # * mesg - +String+            - An optional assertion-failed message.
	def assert_text_in_field(name, text, mesg=nil)
    if mesg.nil? then
      assert(@@browser.textField(:name, name).verify_contains(text), "couldn't find in field #{name}: [#{text}]")
    else
      assert(@@browser.textField(:name, name).verify_contains(text), mesg)
    end
	end

	#
	# * how - symbol - the way we look for the object. Supported values are
	#                - :name
	#                - :id
	#                - :index          
	# * what - string                      - What field, id or name to examine.
	# * text - string/Array of Strings     - The string or array of strings to search for.
	# * mesg - Optional! string            - Set this if you want to supply your own error message
 	def assert_text_in_combobox_wrapper(how, what, text, mesg=nil)
		assert(@@browser.selectBox(how, what), "could not find a combobox with what: #{what} and how: #{how}")
		selectedItems = @@browser.selectBox(how, what).getSelectedItems
		
		if text.kind_of? String
			if mesg.nil? then
				assert(selectedItems[0] == text, "couldn't find text in combobox with #{how}: #{what} - [#{text}], had [#{selectedItems[0]}]")
			else
				assert(selectedItems[0] == text, mesg)
			end
			
		elsif text.kind_of? Array
			if mesg.nil? then
				text.each do |item|
					assert(selectedItems.include?(item), "couldn't find text in combobox  with #{how}: #{what} - [#{text}], had [#{selectedItems}]")
				end
			else
				text.each do |item|
					assert(selectedItems.include?(item), mesg)
				end
			end
		end
	end
	

	# This method returns true|false if the text is selected in the combobox
	# with the supplied name.
	#
	# * name - string                      - Name of field to examine.
	# * text - string/Array of Strings     - The string or array of strings to search for.
	# * mesg - Optional! string            - Set this if you want to supply your own error message
	def assert_text_in_combobox_by_name(name, text, mesg=nil)
		assert_text_in_combobox_wrapper(:name, name, text, mesg)
	end

	# FIXME: how to use?
	# This method returns true|false if the text is selected in the combobox
	# with the supplied index.
	#
	# * index - string                     - Index of field to examine.
	# * text - string/Array of Strings     - The string or array of strings to search for.
	# * mesg - Optional! string            - Set this if you want to supply your own error message
	#def assert_text_in_combobox_by_index(index, text, mesg=nil)
	#	assert_text_in_combobox_wrapper(:index, name, text, mesg)
	#end

	# This method returns true|false if the text is selected in the combobox
	# with the supplied id.
	#
	# * id - string                        - Id of field to examine.
	# * text - string/Array of Strings     - The string or array of strings to search for.
	# * mesg - Optional! string            - Set this if you want to supply your own error message
	def assert_text_in_combobox_by_id(id, text, mesg=nil)
		assert_text_in_combobox_wrapper(:id, name, text, mesg)
	end



  # Close the browser window.  Useful for automated test suites to reduce
  # test interaction.
	def close_browser
		@@browser.getIE.quit
		sleep 2
	end


  # Tell the browser to cick the Back button.
	def go_back
		@@browser.back
	end


  # Tell the browser to cick the Forward button.
	def go_forward
		@@browser.forward
	end


  # Fill a series of text fields.  This takes a hash of textfield names to
  # values for those fields.
  #
  # Example:
  #
  #   fill_text_fields {
  #     'username' => 'joe',
  #     'password' => 'blahblah',
  #     'email' => 'joe@blahblah.com',
  #     'favorite_num' => 42
  #   }
	def fill_text_fields(data)
		data.each do |field, value|
			@@browser.textField(:name, field).set(value)
		end
	end


  # Fill a single textfield with a value
	def fill_text_field(field_name, text)
		@@browser.textField(:name, field_name).set(text)
	end


  # Some browsers (i.e. IE) need to be waited on before more actions can be
  # performed.  Most action methods in Watir::Simple already call this before
  # and after.
	def wait_for_browser
		@@browser.waitForIE
	end


	def combobox_default_selection(name)
    # FIXME _where_ is this used?
		@@browser.selectBox(:name, name).value
	end


  # Returns the number of times +text+ appears in the body text of the page.
	def count_instances_of(text)
		@@browser.getDocument.body.innerText.scan(text).size
	end


  # Make a Test::Unit assertion that an image exists on the page with the given
  # +src+ attribute.
  #
  # * mesg - +String+            - An optional assertion-failed message.
	def assert_image_with_src(src, mesg=nil)
		if mesg.nil? then
			assert( get_image_with_src(src) != nil, "image with src: [#{src}] is not present")
		else
			assert( get_image_with_src(src) != nil, mesg)
		end
	end


  # Make a Test::Unit assertion that an image exists on the page with the given
  # +id+ attribute. (Preferred method)
  #
  # * mesg - +String+            - An optional assertion-failed message.
	def assert_image_with_id(id, mesg=nil)
		if mesg.nil? then
			assert( get_image_with_id(id) != nil, "image with id: [#{id}] is not present")
		else
			assert( get_image_with_id(id) != nil, mesg)
		end
	end


  # A convenience method to wait at both ends of an operation for the browser
  # to catch up.
  def wait_before_and_after
    wait_for_browser
    yield
    wait_for_browser
  end


  #### PRIVATE METHODS BEYOND THIS POINT
  private
  ####

	def get_image_with_src(src)
    @@browser.image(:src, src)
	end


	def get_image_with_id(id)
	  @@browser.image(:id, id)
	end

  end
end
