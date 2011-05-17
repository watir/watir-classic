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
      @file_download_window ||= wait_for_window('File Download', /save this file/)
      @file_download_window
    end

    def save_file_button
      file_download_window.button(:value => '&Save')
    end

    def open_file_button
      file_download_window.button(:value => 'Open')
    end

    # Save As Dialog
    def save_as_window
      @save_window ||= wait_for_window('Save As')
      @save_window
    end

    def set_file_name(path_to_file)
      save_as_window.text_field(:class => 'Edit').set path_to_file
    end

    def save_button
      save_as_window.button(:value=>'&Save')
    end

    def wait_for_window(title, text=nil)
      args = {:title => title}
      args.update(:text => text) if text
      window = nil
      Watir::Wait.until {
        window = ::RAutomation::Window.new(args)
        window.exists?
      }
      window
    end

  end
end
