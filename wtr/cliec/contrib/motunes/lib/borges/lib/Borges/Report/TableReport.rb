class Borges::TableReport < Borges::Report

  def choose_row_column(aRow, aColumn)
    aColumn.chooseRow(aRow)
  end

  def color_for_row_number(aNumber)
    return @rowColors.at_ifAbsent(((aNumber-1 / @rowPeriod) % @rowColors.size) + 1, proc do 'white' end)
  end

  def columns(anArray)
    @columns = anArray
  end

  def initialize
    super initialize
    @isReversed = false
    @columns = []
    @sortColumn = StateHolder.new
    @rowColors = %w(white lightyellow)
    @rowPeriod = 3
  end

  def is_reversed
    return @isReversed
  end

  def render_column_row_on(aColumn, aRow, r)
    text = aColumn.textForRow(aRow)
    text = '&nbsp;' if text.empty?
    r.tableData do
      unless aColumn.canChoose then
        r.text(text)
      else
        r.anchorWithAction_text(proc do
          self.chooseRow_column(aRow, aColumn)
        end, text)
      end
    end
  end

  def render_content_on(r)
    r.attributeAt_put('cellspacing', 0)
    r.attributeAt_put('cellpadding', 5)
    r.table do
      self.renderTableHeaderOn(r)
      self.renderRowsOn(r)
      self.renderTableFooterOn(r)
    end
  end

  def render_footer_for_column_on(aColumn, r)
    r.tableHeading do
      r.text(aColumn.totalForRows(rows))
    end
  end

  def render_header_for_column_on(aColumn, r)
    r.tableHeading do
      if aColumn.canSort then
        r.anchorWithAction_text(proc do self.sortColumn(aColumn) end,
        aColumn.title)
      else
        r.text(aColumn.title)
      end
    end
  end

  def render_row_number_item_on(index, row, r)
    r.attributeAt_put('bgcolor', self.colorForRowNumber(index))
    r.tableRow do
      @columns.each do |ea|
        self.renderColumn_row_on(ea, row, r)
      end
    end
  end

  def render_rows_on(r)
    self.rows.each_with_index do |row, i|
      self.renderRowNumber_item_on(i, row, r)
    end
  end

  def render_table_footer_on(r)
    r tableRow do
      @columns.each do |ea|
        self.renderFooterForColumn_on(ea, r)
      end
    end
  end

  def render_table_header_on(r)
    r.tableRow do
      @columns.each do |ea|
        self.renderHeaderForColumn_on(ea, r)
      end
    end
  end

  def row_colors(colorArray)
    @rowColors = colorArray
  end

  def row_period(aNumber)
    @rowPeriod = aNumber
  end

  def rows
    return rows if sortColumn.nil?

    r = self.sortColumn.sortRows(rows)
    if self.isReversed then
      return r.reversed
    else
      return r
    end
  end

  def sort_column(arg = :arg)
    move_method('key=', 'key') unless arg == :noarg
    return @sortColumn.contents
  end

  def sort_column=(anObject)
    if anObject == self.sortColumn then
      @isReversed = (not @isReversed)
    else
      @isReversed = false
    end
    @sortColumn.contents(anObject)
  end

end

