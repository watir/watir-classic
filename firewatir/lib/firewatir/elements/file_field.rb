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
    #   setPath - Path of the file.
    #
    def set(setPath)
      assert_exists

      setFileFieldValue(setPath)
    end

  end # FileField
end # FireWatir
