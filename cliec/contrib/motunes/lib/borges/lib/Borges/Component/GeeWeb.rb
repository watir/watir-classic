class Borges::GeeWeb < Borges::Component

  def allPages
    @allPages = self.collectPageSelectors if @allPages.nil?
    return @allPages
  end

  def choosePage(aSymbol)
    Transcript.cr
    Transcript.show(aSymbol)
    @page.contents(aSymbol)
  end

  def collectPageSelectors
    return self.class.allSelectors.asSortedCollection.select do |ea|
      ea.beginsWith('page')
    end
  end

  def componentNamed(aString)
    return @components.at_ifAbsentPut(aString, proc do
      self.perform(aString.intern)
    end)
  end

  def initialize
    @components = Dictionary.new
    @page = StateHolder.new.contents(self.allPages.first)
  end

  def nextPage
    self.choosePage(self.allPages.after(@page.contents))
  end

  def prevPage
    self.choosePage(self.allPages.before(@page.contents))
  end

  def renderComponent_on(aString, r)
    return self if aString.empty?
    r.divClass_with('component', self.componentNamed(aString))
  end

  def renderContentOn(r)
    self.renderPageSelectorOn(r)
    r.paragraph
  
    r.attributes.cellpadding(10)
    r.attributes.cellspacing(0)
    r.attributes.width('90%')
    r.attributes.height('80%')

    r.table do
      self.renderPaneOn(r)
    
      unless @page.contents == self.allPages.last then
        r.cssId(:nav)
        r.tableRowWith do
          r.anchorWithAction_text(proc do self.nextPage end, 'next page')
        end
      end
    end

    self.renderPageSelectorOn(r)
  end

  def renderPageSelectorOn(r)
    r.cssId(:nav)

    r.center do
      if @page.contents == self.allPages.first then
        r.text('<<')
      else
        r.anchorWithAction_text(proc do self.prevPage end, '<<')
      end

      self.allPages.each_with_index do |ea, i|
        r.space
        text = ea.copyAfter(?e)

        if @page.contents == ea then
          r.text(i)
        else
          r.anchorWithAction_text(proc do
            self.choosePage(ea) end,
            i)
        end
      end

      r.space

      if @page.contents == self.allPages.last then
        r.text('>>')
      else
        r.anchorWithAction_text(proc do self.nextPage end, '>>')
      end
    end
  end

  def renderPaneOn(r)
    stream = self.text.readStream
    until stream.atEnd do
      r.attributeAt_put('valign', 'top')
      r.table_row do
        r.attributeAt_put('width', 400)
        r.cssId('text')
        r.table_data do
          self.renderText_on(stream.upToAll('{{'), r)
        end

        r.attributeAt_put('width', 20)
        r.cssId('spacer')
        r.table_data do end

        r.cssId('components')
        r.table_data do
          self.renderComponent_on(stream.upToAll('}}'), r)
        end
      end
    end
  end

  def renderText_on(aString, r)
    r.text(aString)
  end

  def style
    return "
      body {background-color: #FFFF99}
      #text {background-color: #F8F8EF}
      #spacer {background-color: #F8F8EF}
      #components {background-color: lightblue}
      .component {}
      #nav a {text-decoration: none}
      #nav {font-weight: bold}
      "
  end

  def text
    return self.perform(@page.contents)
  end

end

