module Watir
  class FileDownloadLink < Watir::Link

    def set(x)
      click_no_wait
      save_file_button.click
      set_file_name x
      save_button.click
    end

    def open
      click_no_wait
      open_file_button.click
    end

    # File Download Dialog
    def file_download_window
      wait_for_window('File Download')
    end

    def save_file_button
      file_download_window.button(:value => '&Save')
    end

    def open_file_button
      file_download_window.button(:value => 'Open')
    end

    # Save As Dialog
    def save_as_window
      wait_for_window('Save As')
    end

    def set_file_name(path_to_file)
      save_as_window.text_field(:value => 'Edit').set path_to_file
    end

    def save_button
      save_as_window.button('&Save')
    end


    def wait_for_window(title)
      window = ::RAutomation::Window.new(:title => title)
      Watir::Wait.until {window.exists?}
      window
    end

  end
end
