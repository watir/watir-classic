class Browser < Component

  def accept
    if Utilities.authorInitialsPerSe.isEmpty then
      Utilities.setAuthorInitials(self.request_default('Please enter your initials:', ''))
    end
    @message = nil
    save = @contents
    @model.contents_notifying(@contents, self)
    @contents = save
  end

  def columnView(columnName)
    return PluggableSelectBox.on_list_selected_changeSelected(@model,
      "#{columnName}List".intern
      "#{columnName}ListIndex".intern
      "#{columnName}ListIndex:".intern)
  end

  def contents
    return @contents
  end

  def contents(aString)
    @contents = aString
  end

  def self.fullOnClass(aClass)
    return self.new.model(Browser.new.setClass_selector(aClass, nil))
  end

  def initialize
    self.model(Browser.new)
  end

  def model
    return @model 
  end

  def model(aBrowserModel)
    @model = aBrowserModel
    @model.addDependent(self)
    self.session.register_for_backtracking(@model)
    @contents = @model.contents
  end

  def notify_at_in(aString, location, sourceStream)
    @message = aString.allButLast(3)
  end

  def renderColumnsOn(r)
    cols = [:systemCategory :class :messageCategory :message].collect do |sel|
      self.columnView(sel)
    end
  
    r.table do
      r.tableRow do
        cols.each do |ea|
          r.tableData do r.render(ea) end
        end
      end
    end
  end

  def renderContentOn(r)
    self.renderColumnsOn(r)
    self.renderModeButtonsOn(r)
    self.renderMessageOn(r)
    self.renderContentPaneOn(r)
  end

  def renderContentPaneOn(r)
    r.form do
      r.textAreaOn_of(:contents, self)
      r.break
      r.submitButtonOn_of(:accept, self)
    end
  end

  def renderMessageOn(r)
    r.bold(@message) unless @message.nil?
  end

  def renderModeButtonsOn(r)
    r.form do
      r.submitButtonWithAction_text(proc do self.showInstance end, 'instance')
      r.submitButtonWithAction_text(proc do self.showHelp end, 'help')
      r.submitButtonWithAction_text(proc do self.showClass end, 'class')
    end
  end

  def select

  end

  def selectFrom_to(aPos, anotherPos)

  end

  def selectionInterval
    return 1...1
  end

  def showClass
    self.model.indicateClassMessages
  end

  def showHelp
    self.model.plusButtonHit
  end

  def showInstance
    self.model.indicateInstanceMessages
  end

  def style
  
    return "
    #contents {width: 80%; height: 200px; font-family: serif; font-size: 12pt}
    "
  end

  def text
    return Text.fromString('')
  end

  def update(aSymbol)
    @contents = @model.contents
  end

end

