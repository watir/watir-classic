class Inspector < Component

  def canInspect(anObject)
    return anObject isNumber or: do (Array with: nil with: true with: false) includes: anObject end
  end

  def chooseObject_named(anObject, aString)
    @path pushSegment: anObject name: aString
  end

  def initialize
    @path = Path.new
  end

  def object
    return @path currentSegment
  end

  def object(anObject)
    @path pushSegment: anObject name: anObject printString
  end

  def self.on(anObject)
    return self.new object: anObject
  end

  def renderContentOn(html)
    super renderContentOn: html
    html render: @path
    html heading: (self.object printStringLimitedTo: 50)
    self.renderMembersOn: html
  end

  def renderMembersOn(html)
    members = self.object inspectorFields
    return self if members isEmpty
    html bold: 'Members: '
    html attributeAt: 'border' put: 1
    html table: do
      members associationsDo: do |assoc| 
        self 
        renderRowForObject: assoc value
        named: assoc key
        on: html
      end
    end
  end

  def renderRowForObject_named_on(anObject, aString, html)
    html tableRow: do
      html tableData: do 
        if self.canInspect: anObject then
          html text: aString
        else
          html anchorWithAction: do
            self.chooseObject: anObject named: aString
          end text: aString
        end
      end
      html tableData: do
        html text: (anObject printStringLimitedTo: 100)
      end
    end
  end

end

