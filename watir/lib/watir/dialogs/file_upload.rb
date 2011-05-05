
module Watir
  class FileUpload < InputElement
    #:stopdoc:
    INPUT_TYPES = ["file"]
    WINDOW_TITLES = ['Choose file', 'Choose File to Upload']
    #:startdoc:

    def set(path_to_file)
      assert_exists
      click_no_wait
      set_file_name path_to_file
      open_button.click
      handle_missing_file path_to_file
    end

    def set_file_name(path_to_file)
      file_upload_window.text_field(:class => 'Edit', :index => 0).set path_to_file
    end

    def open_button
      file_upload_window.button(:value => '&Open')
    end

    def cancel_button
      file_upload_window.button(:value => 'Cancel')
    end

    def handle_missing_file(path_to_file)
      #TODO
#       window = Watir::Dialog::Window.new(:title => title, :element_title => 'OK', :class => 'Button')
#      if window.exists?
#         window.button('OK').click
#        raise "File not found: #{path_to_file}"
#      end
#      cancel_button.click
    end

    def file_upload_window
      unless @window
        Watir::Wait.until {
          @window = ::RAutomation::Window.new(:title => /^(#{WINDOW_TITLES.join('|')})$/)
          @window.exists?
        }
      end
      @window
    end

  end
end
