class Borges::ToolFrame < Borges::Component

  def actions
    return [:newSession, :configure]
  end

  def configure
    self.call(ApplicationEditor.new.application(self.session.application))
  end

  def container
    return @child
  end

  def contents(aComponent)
    @child = aComponent
  end

  def newSession
    session.return_response(RedirectResponse.location(session.base_path))
  end

  def self.on(aComponent)
    return self.new.contents(aComponent)
  end

  def open_tool(aToolClass)
    self.call_title_content(Window.new,
          aToolClass.title,
          aToolClass.new.root(@child))
  end

  def render_content_on(r)
    r.divNamed_with('frameContent', @child)
    self.renderToolbarOn(r)
  end

  def render_toolbar_on(r)
    r.paragraph
    r.divNamed_with('toolbar',
    proc do
      self.actions.each do |ea|
        r.anchorOn_of(ea, self)
        r.space
      end

      self.tools.each do |ea|
        r.anchorWithAction_text(proc do
          self.openTool(ea)
        end, ea.linkText)
        r.space
      end
      r.space
      r.text(self.session.footprint)
    end)
  end

  def style
  return "
    #toolbar {position: fixed; bottom: 0; left: 0; right: 0; margin-top: 40px; padding: 3px; clear: both; background: lightgrey; font-size: 10pt}
    #toolbar-profile {margin-top: 40px; padding: 3px; clear: both; background: lightgrey; font-size: 10pt}
  "
  end

  def tools
    return Tool.allSubclasses
  end

end

