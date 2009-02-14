module FireWatir
  #
  # Description:
  #   Class for Hidden Field element.
  #
  class Hidden < TextField
    INPUT_TYPES =  ["hidden"]

    #
    # Description:
    #   Sets the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    # Input:
    #   n - Value to be set.
    #
    def set(n)
      self.value=n
    end

    #
    # Description:
    #   Appends the value to the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    # Input:
    #   n - Value to be appended.
    #
    def append(n)
      self.value = self.value.to_s + n.to_s
    end

    #
    # Description:
    #   Clears the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    def clear
      self.value = ""
    end

    #
    # Description:
    #   Does nothing, as you cant set focus to a hidden field. Overridden here so that exception doesn't occurs.
    #
    def focus
    end

    #
    # Description:
    #   Hidden element is never visible - returns false.
    #
    def visible?
      assert_exists
      false
    end

  end # Hidden
end # FireWatir
