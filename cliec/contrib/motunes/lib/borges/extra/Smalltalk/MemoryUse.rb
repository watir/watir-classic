class MemoryUse < Component

  def buildTable
    return TableReport.new
    rowPeriod: 1
    rowColors: %w(lightgrey white)
    rows: @sizes keys asSortedCollection
    columns: 
    (Array with: (ReportColumn selector: :yourself title: 'Class')
    with: ( ReportColumnenew
    title: 'Instances'
    valueBlock: do |ea| @instances at: ea end)
    with:
    (ReportColumn new
    title: 'Total Size'
    valueBlock: do |ea| @sizes at: ea end))
  end

  def renderContentOn(html)
    html bold: self.totalInstances asString, ' instances in ', self.totalSizeString
    html render: @table
  end

  def root(anObject)
    @root = anObject
    segment = ImageSegment new copyFromRoots: (Array with: @root) sizeHint: 100000
    results = segment doSpaceAnalysis
    @instances = results first
    @sizes = results second
    @table = self.buildTable
  end

  def totalInstances
    return @instances detectSum: do |ea| ea end
  end

  def totalSize
    return @sizes detectSum: do |ea| ea end
  end

  def totalSizeString
    size = self.totalSize
    unit = 'bytes'
    if size > 1024 then
      size = size / 1024
      unit = 'kB'
      if size > 1024 then
        size = size / 1024
        unit = 'MB'
      end
    end

    return (size printShowingDecimalPlaces: 1), ' ', unit
  end

end

