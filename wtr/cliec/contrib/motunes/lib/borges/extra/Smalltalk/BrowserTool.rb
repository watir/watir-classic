class BrowserTool < Tool

  def go
    call(Browser.fullOnClass(root.active_controller.class))
  end

  def self.linkText
    return 'Browse'
  end

  def self.title
    return 'System Browser'
  end

end

