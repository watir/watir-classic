class PrettyPrinter < Component

  def self.on(aComponent)
    return self.new.root(aComponent)
  end

  def render_content_on(r)
    doc = HtmlResponse.new
    context = RenderingContext.new
    context.actionUrl('action')
    context.callbacks(CallbackStore.new)
    context.document(doc)

    @root.renderWithContext(context)
  
    r.divClass_with('html-source', proc do
      doc.renderOn(r)
    end)
  end

  def root(aComponent)
    @root = aComponent
  end

  def style
    return '
  .html-source {
    font-family: courier, serif;
    font-size: 9pt;
  }
  
  .tag-known {
    color: purple;
    font-weight: bold;
  }
  
  .attribute-known {
    font-weight: bold;
  }
  
  .attribute-value {
    color: blue;
  }
  
  .template {
    color: blue;
    font-weight: bold;
  }
  
  '
  end

end

