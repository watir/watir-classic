class WSMCardList < WSMComponent

  def cards(aCollection)
    @cards = aCollection
  end

  def renderContentOn(html)
    html heading: 'Choose a package:' level: 3
    html render: self.report
  end

  def report
    if @report.nil? then
      @report = TableReport.new
      rows: @cards
      columns:
      (Array
      with:
      (ReportColumn selector: :name title: 'Name' onClick: do |i|
        self.answer: i
      end)
      with: (ReportColumn selector: :smartVersion title: 'Version')
      with: (ReportColumn selector: :summary))
    end

    return @report
  end

end

