module Watir
  # Returned by {Container#file_field}.
  class FileField < InputElement
    # File upload dialog titles to search for.
    #
    # @example When the title of your IE dialog is missing, add a new one:
    #   Watir::FileField::WINDOW_TITLES << "My missing title"    
    WINDOW_TITLES = [/choose file( to upload)?/i, "Elegir archivos para cargar", "Datei zum Hochladen"] 

    # File upload dialog "OK" button values to search for.
    #
    # @example When the "OK" button of your IE is missing, add a new one:
    #   Watir::FileField::OK_BUTTON_VALUES << "My missing button value"    
    OK_BUTTON_VALUES = ['&Open', '&Abrir', '&ffnen']

    # File upload dialog "Cancel" button values to search for.
    #
    # @example When the "Cancel" button of your IE is missing, add a new one:
    #   Watir::FileField::CANCEL_BUTTON_VALUES << "My missing button value"    
    CANCEL_BUTTON_VALUES = ['Cancel', 'Abbrechen']

    # Set the path of the file field.
    #
    # @example
    #   browser.file_field.set("c:/foo/bar.txt")
    #
    # @param [String] file_path absolute path to existing file.
    # @macro exists
    # @raise [Errno::ENOENT] when file does not exist.
    def set(file_path)
      assert_file_exists(file_path)
      assert_exists
      click_no_wait
      set_file_name file_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
      open_button.click
      Wait.until(5) {value.include?(File.basename(file_path))}
    end

    alias_method :value=, :set

    private

    def assert_file_exists(file_path)
      raise Errno::ENOENT, "#{file_path} has to exist to set!" unless File.exists?(file_path)
    end

    def set_file_name(path_to_file)
      file_upload_window.text_field(:class => 'Edit', :index => 0).set path_to_file
    end

    def open_button
      file_upload_window.button(:value => formatted_regexp(OK_BUTTON_VALUES))
    end

    def cancel_button
      file_upload_window.button(:value => formatted_regexp(CANCEL_BUTTON_VALUES))
    end

    def file_upload_window
      @window ||= RAutomation::Window.new(:title => formatted_regexp(WINDOW_TITLES))
    end

    private

    def formatted_regexp(values)
      Regexp.new("^#{Regexp.union values}$", Regexp::IGNORECASE)
    end

  end
end
