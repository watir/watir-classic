class SingleClassBrowser < Component

  def categoryView
    return PluggableSelectBox.on_list_selected_changeSelected(@browser,
    :messageCategoryList,
    :messageCategoryListIndex,
    'messageCategoryListIndex:'.intern)
  end

  def class(aClass)
    @browser = Browser.new.setClass_selector(aClass, nil)
  end

  def self.example
    return self.on(SingleClassBrowser)
  end

  def messageView
    return PluggableSelectBox.on_list_selected_changeSelected(@browser,
    :messageList,
    :messageListIndex,
    'messageListIndex:'.intern)
  end

  def self.on(aClass)
    return self.new.class(aClass)
  end

  def renderContentOn(r)
    r.heading(@browser.selectedClassName)
    r.attributeAt_put('width', 500)
    r.table do
      r.tableRow do
        r.tableData(self.categoryView)
        r.tableData(self.messageView)
        r.attributeAt_put('width', 500)
        r.tableData do end
      end

      r.tableRowWith_span(proc do
        r.preformatted: @browser contents
      end, 3)
    end
  end

end

