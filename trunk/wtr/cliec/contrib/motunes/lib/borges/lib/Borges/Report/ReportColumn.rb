class Borges::ReportColumn

  def can_choose
    return (not @clickBlock.nil?)
  end

  def can_sort
    return (not @sortBlock.nil?)
  end

  def choose_row(row)
    return @clickBlock.value(row)
  end

  def click_block(aBlock)
    @clickBlock = aBlock
  end

  def column_click_block(aBlock)
    self.clickBlock do |r|
      aBlock.call(self.valueForRow(r))
    end
  end

  def format_block(anObject)
    @formatBlock = anObject
  end

  def has_total(aBoolean)
    @hasTotal = aBoolean 
  end

  def index(aNumber)
    @valueBlock = proc do |row|
      row.at(aNumber)
    end
  end

  def initialize
    @formatBlock = proc do |x| x asString end
    @sortBlock = proc do |a, b| a <= b end
    @valueBlock = proc do |row| nil end
    @clickBlock = nil
    @title = 'Untitled'
    @hasTotal = false
  end

  def self.selector(aSymbol)
    return self.selector_title(aSymbol, aSymbol.capitalize)
  end

  def selector(aSymbol)
    @valueBlock = proc do |row|
      row.perform(aSymbol)
    end
  end

  def self.selector_title(aSymbol, aString)
    return self.selector_title_onClick(aSymbol, aString, nil)
  end

  def self.selector_title_on_click(aSymbol, aString, aBlock)
    rc = self.new
    rc.title(aString)
    rc.selector(aSymbol)
    rc.clickBlock(aBlock)
    return rc
  end

  def sort_block(anObject)
    @sortBlock = anObject
  end

  def sort_rows(anArray)
    assocs = anArray.collect do |ea|
      [ea, self.valueForRow(ea)]
    end

    assocs = assocs.sort do |a, b|
      @sortBlock.call(a.value, b.value)
    end

    return assocs.collect do |ea| ea.key end
  end

  def text_for_row(row)
    return @formatBlock.call(self.valueForRow(row))
  end

  def title(arg = :noarg)
    move_method('key=', 'key') unless arg == :noarg

    return @title
  end

  def title=(aString)
    @title = aString
  end

  def total_for_rows(aCollection)
    unless @hasTotal then
      ''
    else
      @formatBlock.call(aCollection.detectSum do |r|
        self.valueForRow(r)
      end)
    end
  end

  def value_block(aBlock)
    @valueBlock = aBlock
  end

  def value_for_row(row)
    return @valueBlock.value(row)
  end

end

