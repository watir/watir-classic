class Borges::HtmlRenderer < Borges::HtmlBuilder

  attr_accessor :action_url, :callbacks

  def anchor(anchor_text, &block)
    open_anchor(&block)
    text(anchor_text)
    close
  end

  def anchor_on(sym, obj)
    element_id(sym)
    anchor(label_for(sym)) do obj.send(sym) end
  end

  def boolean_menu(bool, labels = [:Yes, :No], &block)
    select([true, false], bool, proc do |b|
        b ? labels.at(0) : labels.at(1)
      end, &block)
  end

  def boolean_menu_on(sym, obj)
    element_id(sym)
    boolean_menu(obj.send(sym), &callback_for_setter_on(sym, obj))
  end

  def callback_for_setter_on(sym, obj)
    return proc do |val|
      obj.send("#{sym}=", val) 
    end
  end

  def checkbox(value, &block)
    #callbackBlock.fixTemps
    @attributes['checked'] = value

    update_key = value_input('checkbox', 'true') do |v|
      block.call(v == 'false')
    end
      
    input('hidden', update_key, 'false') if value
  end

  def context
    return Borges::RenderingContext.new(document, action_url, callbacks)
  end

  def default_action(&block)
    input('hidden', @callbacks.register_action_callback(&block))
  end

  def file_upload(&block)
    input('file', @callbacks.register_callback(&block))
  end

  def form(&block)
    open_form
    block.call
    close
  end

  def initialize(rendering_context)
    super()
    @document = rendering_context.document
    @action_url = rendering_context.action_url
    @callbacks = rendering_context.callbacks
  end

  def label_for(selector)
    label = selector.to_s
    label.gsub!('_', ' ')
    label.gsub!(/\w+/) do |w|
      w.capitalize! unless %w(Of In At A Or To By).include? w
      w
    end

    return label
  end

  def open_anchor(&block)
    @attributes['href'] = url_for(&block)
    open_tag('a')
  end

  def open_form
    @attributes['method'] = 'POST'
    @attributes['action'] = @action_url
    open_tag('form')
  end

  def open_select
    @attributes[:name] = @callbacks.register_dispatch_callback
    open_tag('select')
  end

  def option(label, selected, &callback)
    @attributes[:selected] = selected
    @attributes[:value] = @callbacks.register_callback(&callback)
    
    open_tag('option')
    text(label)
    close
  end

  def radio_button(group, value, &block)
    @attributes['checked'] = value
    
    input('radio', group, @callbacks.register_callback(&block))
  end

  def radio_group
    return @callbacks.register_dispatch_callback
  end

  def select(list, selected, labels_block = nil, &callback)
    open_select
  
    list.each do |item|
      label = labels_block.nil? ? item : labels_block.call(item)

      option(label, item == selected) do
        callback.call(item)
      end
    end

    close
  end

  def style(css)
    style_link(url_for_document(css, 'text/css'))
  end

  ##
  # FIX submit_button doesn't require a block

  def submit_button(text = 'Submit', &block)
    @attributes['value'] = text
    input('submit', @callbacks.register_action_callback(&block))
  end

  def submit_button_on(sym, obj)
    element_id(sym)
    submit_button(label_for(sym)) do
      obj.send(sym)
    end
      
  end

  def text_area(value, &block)
    callback = nil

    if value.nil? then
      callback = proc do |v|
        block.call(v == '' ? nil : v)
      end
    else
      callback = block
    end

    attributes['name'] = @callbacks.register_callback(&callback)
    open_tag('textarea')
    render(value)
    close
  end

  def text_input(value, &callback)
    value_input('text', value, &callback)
  end

  def text_input_on(sym, obj)
    element_id(sym)
    text_input(obj.send(sym), &callback_for_setter_on(sym, obj))
  end

  def url_for(&block)
    return "#{@action_url}?#{@callbacks.register_action_callback(&block)}"
  end

  def url_for_document(obj, mime_type = nil)
    return Borges::Session.current_session.application.url_for_request_handler(
      Borges::DocumentHandler.new(obj, mime_type))
  end

  def value_input(input_type, value, &block)
    callback = block

    if value.kind_of? Integer then
      callback = proc do |v|
        block.call(v.to_i)
      end

    elsif value.kind_of? Float then
      callback = proc do |v|
        block.call(v == value ? anObject : v.to_f)
      end

    elsif value.nil? then
      value = ''

      callback = proc do |v|
        block.call(v == '' ? nil : v)
      end

    end

    update_key = @callbacks.register_callback(&callback)
    input(input_type, update_key, value)
    return update_key
  end

=begin

  def anchorWithAction_do(actionBlock, linkBlock)
    self.openAnchorWithAction(actionBlock)
    linkBlock.call
    self.close
  end

  def anchorWithAction_form(actionBlock, aForm)
    self.anchorWithAction_do(actionBlock,
      proc do self.imageWithForm(aForm) end)
  end

  def anchorWithDocument_mimeType_text(anObject, mimeType, aString)
    self.openAnchorWithDocument_mimeType(anObject, mimeType)
    self.text(aString)
    self.close
  end

  def anchorWithDocument_text(anObject, aString)
    self.anchorWithDocument_mimeType_text(anObject, nil, aString)
  end

  def booleanMenuWithValue_callback(aBoolean, callbackBlock)
    self.booleanMenuWithValue_callback_labels(aBoolean, callbackBlock,
      [:Yes, :No])
  end

  def checkboxOn_of(aSymbol, anObject)
    self.cssId(aSymbol)
    self.checkboxWithValue_callback(anObject.perform(aSymbol),
      self.callbackForSelector_of(aSymbol, anObject))
  end

  def hiddenInputWithValue_callback(anObject, callbackBlock)
    self.valueInputOfType_value_callback('hidden',
      anObject, callbackBlock)
  end

  def imageMapWithAction_form(aBlock, aForm)
    point = ValueHolder.new

    pointKey = @callbacks.register_callback do |ptString|
      point.contents(self.parseImageMap(ptString))
    end

    actionKey = @callbacks.register_action_callback do
      aBlock.call(point.contents)
    end

    self.attributeAt_put('href', "#{@action_url}?#{actionKey}&#{pointKey}=")

    self.tag_do('a', proc do
      self.attributeAt_put('border', 0)
      self.attributeAt_put('ismap', true)
      self.imageWithForm(aForm)
    end)
  end

  def imageWithForm(aForm)
    self.image_width_height(self.urlForDocument(aForm), aForm.width, aForm.height)
  end

  def labelledRowForCheckboxOn_of(aSymbol, anObject)
    self.tableRowWithLabel_column(self.labelForSelector(aSymbol),
      proc do self.checkboxOn_of(aSymbol, anObject) end)
  end

  def labelledRowForList_on_of(aCollection, aSymbol, anObject)
    self.tableRowWithLabel_column(self.labelForSelector(aSymbol),
      proc do self.selectFromList_selected_callback(aCollection,
        anObject.perform(aSymbol),
        self.callbackForSelector_of(aSymbol, anObject))
      end)
  end

  def labelledRowForTextAreaOn_of(aSymbol, anObject)
    self.tableRowWithLabel_column(self.labelForSelector(aSymbol),
      proc do self.textAreaOn_of(aSymbol, anObject) end)
  end

  def labelledRowForTextInputOn_of(aSymbol, anObject)
    self.labelledRowForTextInputOn_of_size(aSymbol, anObject, nil)
  end

  def labelledRowForTextInputOn_of_size(aSymbol, anObject, sizeIntegerOrNil)
    self.tableRowWithLabel_column(self.labelForSelector(aSymbol),
      proc do
        unless sizeIntegerOrNil.nil? then
          self.attributeAt_put(:size, sizeIntegerOrNil)
        end
        self.textInputOn_of(aSymbol, anObject)
      end)
  end

  def linkWithScript(jsString)
    self.scriptWithUrl(self.urlForDocument_mimeType(jsString, 'text/javascript'))
  end

  def openAnchorWithDocument_mimeType(anObject, mimeType)
    self.attributeAt_put('href',
      self.urlForDocument_mimeType(anObject, mimeType))
    self.openTag('a')
  end

  def parseImageMap(aString)
    return nil unless '?*,*'.match(aString)

    s = aString.readStream
    s.upTo(??)
    x = s.upTo(?,)
    y = s.upToEnd
    return [x.to_i, y.to_i]
  end

  def passwordInputWithCallback(callbackBlock)
    self.valueInputOfType_value_callback( 'password', '', callbackBlock)
  end

  def selectFromList_selected_callback(aCollection, selectedObject, callbackBlock)
    self.selectFromList_selected_callback_labels(aCollection,
      selectedObject, callbackBlock, proc do |i| i.to_s end)
  end

  def selectInputOn_of_list(selectedSymbol, anObject, aCollection)
    self.selectFromList_selected_callback(aCollection,
      anObject.perform(selectedSymbol),
      self.callbackForSelector_of(selectedSymbol, anObject))
  end

  def textAreaOn_of(aSymbol, anObject)
    self.cssId(aSymbol)
    self.textAreaWithValue_callback(anObject.perform(aSymbol),
      self.callbackForSelector_of(aSymbol, anObject))
  end

  def textInputOn_of(aSymbol, anObject)
    cssId(aSymbol)
    textInputWithValue_callback(anObject.perform(aSymbol),
      callbackForSelector_of(aSymbol, anObject))
  end

  def textInputWithCallback(callbackBlock)
    textInputWithValue_callback('', callbackBlock)
  end

  def urlForDocument(anObject)
    return self.urlForDocument_mimeType(anObject, nil)
  end

=end

end

