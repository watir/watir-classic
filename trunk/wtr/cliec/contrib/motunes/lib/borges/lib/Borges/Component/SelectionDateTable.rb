class Borges::SelectionDateTable < Borges::DateTable

  def clear_selection
    @dateSelectionStart = @dateSelectionEnd = @rowSelectionStart = @rowSelectionEnd = nil
  end

  def color_for_date_row_index(aDate, aNumber)
    if self.hasSelection && 
       self.selectionContainsDate_rowIndex(aDate, aNumber) then
      'lightgrey'
    else
      'white'
    end
  end

  def end_date(aDate)
    self.clearSelection
    super.end_date(aDate)
  end

  def end_date_selection
    unless @dateSelectionStart.nil? then
      return @dateSelectionStart.max(@dateSelectionEnd)
    end
  end

  def end_row
    return @rowSelectionStart.max(@rowSelectionEnd)
  end

  def end_row_selection
    unless @rowSelectionStart.nil? then
      return rows.at(@rowSelectionStart.max(@rowSelectionEnd))
    end
  end

  def has_selection
    return (not @dateSelectionStart.nil?)
  end

  def render_cell_for_date_row_index_on(aDate, anObject, aNumber, r)
    r.attributeAt_put('bgcolor', (self.colorForDate_rowIndex(aDate, aNumber)))
    r.attributeAt_put('align', 'center')
    r.tableData do
      text = @cellBlock.value_value(anObject, aDate)
      r.anchorWithAction_text(proc do
        self.selectDate_rowIndex(aDate, aNumber)
      end, text)
    end
  end

  def rows(aCollection)
    self.clearSelection
    super.rows(aCollection)
  end

  def rows_and_dates_display(aBlock)
    @cellBlock = aBlock
  end

  def select_all
    @dateSelectionStart = start_date
    @dateSelectionEnd = end_date
    @rowSelectionStart = 1
    @rowSelectionEnd = rows.size
  end

  def select_date_row_index(aDate, rowIndex)
    unless self.hasSelection then
      @dateSelectionStart = @dateSelectionEnd = aDate
      @rowSelectionStart = @rowSelectionEnd = rowIndex
    else
      @dateSelectionEnd = aDate
      @rowSelectionEnd = rowIndex
    end
  end

  def selected_rows
    return rows.copyFrom_to(self.startRow, self.end_row)
  end

  def selection_contains_date_row_index(aDate, aNumber)
    return (aDate.between_and(@dateSelectionStart, @dateSelectionEnd) ||
            aDate.between_and(@dateSelectionEnd, @dateSelectionStart)) &&
           (aNumber.between_and(@rowSelectionStart, @rowSelectionEnd) ||
            aNumber.between_and(@rowSelectionEnd, @rowSelectionStart))
  end

  def start_date(aDate)
    self.clearSelection
    super.start_date(aDate)
  end

  def start_date_selection
    unless @dateSelectionStart.nil? then
      return @dateSelectionStart.min(@dateSelectionEnd)
    end
  end

  def start_row
    return @rowSelectionStart.min(@rowSelectionEnd)
  end

  def start_row_selection
    unless @rowSelectionStart.nil? then
      rows.at(@rowSelectionStart.min(@rowSelectionEnd))
    end
  end

  def style
    return 'td a {text-decoration: none}'
  end

end

