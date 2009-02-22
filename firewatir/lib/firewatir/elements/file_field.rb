module FireWatir
  #
  # Description:
  #   Class for FileField element.
  #
  class FileField < InputElement
    INPUT_TYPES = ["file"]

    #
    # Description:
    #   Sets the path of the file in the textbox.
    #
    # Input:
    #   path - Path of the file.
    #
    def set(path)
      assert_exists

      path.gsub!("\\", "\\\\\\")

      jssh_socket.send("#{element_object}.value = \"#{path}\";\n", 0)
      read_socket()
      @o.fireEvent("onChange")
      
      @@current_level = 0
    end

  end # FileField
end # FireWatir
