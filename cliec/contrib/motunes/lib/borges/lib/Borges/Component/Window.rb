class Borges::Window < Borges::Component

  def content(aComponent)
    @content = aComponent
  end

  def default_style
  return '
    #window-titlebar {background-color: lightblue; margin-bottom: 10px; width: 100%; }
    #window-title { text-align: right; width: 66% }
    #window-close {text-align: right;}
  '  
  end

  def render_close_button_on(r)
    r.anchorWithAction_text(proc do self.answer end, 'close')
  end

  def render_content_on(r)
    r.title(@title)
    r.attributes.at_put('cellspacing', 0)
    r.table do
      r.cssId('window-titlebar')
      r.tableRow do
          r.cssId('window-title')
          r.tableData(@title)
          r.cssId('window-close')
          r.tableData do self.renderCloseButtonOn(r) end
      end

      r.cssId('window-content')
      r.tableRowWith_span(@content, 2)
    end
  end

  def style(arg = :noarg)
    move_method('key=', 'key') unless arg == :noarg

    return @style.nil? ? self.defaultStyle : @style
  end

  def style=(aString)
    @style = aString
  end

  def title(aString)
    @title = aString
  end

end

