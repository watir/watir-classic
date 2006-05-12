class MethodEditor < Component

  def accept()
    unless (Parser new parseSelector: @source) = @selector then
      return @error = 'Please do not change the method name'
    end
    
    node = 
      Compiler new compile: @source in: @class notifying: self.ifFail: do
        return @error = 'Syntax Error'
      end
    method = node generate: [0, 0, 0, 0]
    
    @class addSelector: @selector withMethod: method
  end

  def self.class_selector(aClass, aSymbol)
    return self.new setClass: aClass selector: aSymbol
  end

  def notify_at_in(anObject, x, y)

  end

  def renderContentOn(html)
    html bold: do html small: @error end
    html form: do
      html attributeAt: 'rows' put: 6; attributeAt: 'cols' put: '35'
      html textAreaWithValue: @source callback: do |t| self.source: t end
      html break
      html submitButtonWithAction: do self.accept end text: 'Accept'
    end
  end

  def setClass_selector(aClass, aSymbol)
    @class = aClass
    @selector = aSymbol
    @source = @class sourceCodeAt: @selector
    @error = nil
  end

  def source(aString)
    @source = aString
    @error = nil
  end

end

