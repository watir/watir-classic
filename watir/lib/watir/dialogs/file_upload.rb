module Watir
  class FileUpload < InputElement
    #:stopdoc:
    INPUT_TYPES = ["file"]
    #:startdoc:

    def set(file_path)
      assert_file_exists(file_path)
      assert_exists
      click_no_wait
      set_file_name file_path
      open_button.click
    end

    def assert_file_exists(file_path)
      raise WatirException, "#{file_path} has to exist to set!" unless File.exists?(file_path)
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

    def file_upload_window
      @window ||= RAutomation::Window.new(:title => /^choose file( to upload)?$/i)
    end

  end
end
