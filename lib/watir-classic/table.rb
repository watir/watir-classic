module Watir

  module TableContainer
    # @return [TableRow] a row in the {Table}.
    # @param [Fixnum] index row number to retrieve.
    # @macro exists
    def [](index)
      assert_exists
      TableRow.new(self, :ole_object => @o.rows.item(index))
    end
    
    # @return [Array<String>] array of table element texts.
    # @macro exists
    def strings
      assert_exists
      rows_memo = []
      @o.rows.each do |row|
        cells_memo = []
        row.cells.each do |cell|
          cells_memo << TableCell.new(self, :ole_object => cell).text.gsub("\r\n","")
        end
        rows_memo << cells_memo
      end
      rows_memo
    end
  end

  module TableElementsContainer

    private

    def table_elements(klass, tags, how, what, ole_collection)
      specifiers = format_specifiers(tags, how, what)
      klass.new(self, specifiers, ole_collection)
    end

  end

  module TableCellsContainer
    include TableElementsContainer

    # @return [TableCellCollection] cells inside of the {Table}.
    # @macro exists
    def cells(how={}, what=nil)
      assert_exists
      table_elements(TableCellCollection, [:th, :td], how, what, @o.cells)
    end

    # @return [TableCell] cell inside of the {Table}.
    # @macro exists
    def cell(how={}, what=nil)
      specifiers = format_specifiers([:th, :td], how, what)
      index = specifiers.delete(:index) || 0
      cells(specifiers)[index]
    end
  end

  module TableRowsContainer
    include TableElementsContainer

    # @return [TableRowCollection] rows inside of the {Table}.
    # @macro exists
    def rows(how={}, what=nil)
      assert_exists
      table_elements(TableRowCollection, [:tr], how, what, @o.rows)
    end

    # @return [TableRow] row inside of the {Table}.
    # @macro exists
    def row(how={}, what=nil)
      specifiers = format_specifiers([:tr], how, what)
      index = specifiers.delete(:index) || 0
      rows(specifiers)[index]
    end
  end

  # Returned by {Container#table}
  class Table < Element
    include TableContainer
    include TableRowsContainer
    include TableCellsContainer

    attr_ole :rules

    # @return [Fixnum] number of rows inside of the table, including rows from
    #   nested tables.
    # @macro exists
    def row_count
      assert_exists
      rows.length
    end

    # @return [Fixnum] number of columns inside of the table, including columns from
    #   nested tables.
    # @param [Fixnum] index the number of row.
    # @macro exists
    def column_count(index=0)
      assert_exists
      rows[index].cells.length
    end
    
    # @return [Array<String>] array of each row's specified column text.
    # @param [Fixnum] columnnumber the number of column to extract text from.
    # @macro exists
    def column_values(columnnumber)
      (0..row_count - 1).collect {|i| self[i][columnnumber].text}
    end
    
    # @return [Array<String>] array of each column's text on specified row.
    # @param [Fixnum] rownumber the number of row to extract column texts from.
    # @macro exists
    def row_values(rownumber)
      (0..column_count(rownumber) - 1).collect {|i| self[rownumber][i].text}
    end
    
    # @return [Array<Hash>] array with hashes of table data.
    # @macro exists
    def hashes
      assert_exists

      headers = []
      @o.rows.item(0).cells.each do |cell|
        headers << TableCell.new(self, :ole_object => cell).text
      end

      rows_memo = []
      i = 0
      @o.rows.each do |row|
        next if row.uniqueID == @o.rows.item(0).uniqueID

        cells_memo = {}
        cells = row.cells
        raise "row at index #{i} has #{cells.length} cells, expected #{headers.length}" if cells.length < headers.length

        j = 0
        cells.each do |cell|
          cells_memo[headers[j]] = TableCell.new(self, :ole_object => cell).text
          j += 1
        end

        rows_memo << cells_memo
        i += 1
      end
      rows_memo
    end

    def to_s
      assert_exists
      r = string_creator
      r += table_string_creator
      r.join("\n")
    end

    private

    # this method is used to populate the properties in the to_s method
    def table_string_creator
      n = []
      n << "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
      n << "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
      n
    end

    # override the highlight method, as if the tables rows are set to have a background color,
    # this will override the table background color, and the normal flash method won't work
    def set_highlight
      perform_highlight do
        @original_border = @o.border.to_i
        @o.border = @original_border + 1
        super
      end
    end

    def clear_highlight
      perform_highlight do
        @o.border = @original_border if @original_border
        super
      end
    end
        
  end

  class TableSection < Element
    include TableContainer
    include TableRowsContainer
    include TableCellsContainer
  end

  # Returned by {Container#tr}.
  class TableRow < Element
    include TableCellsContainer

    # Iterate over each of the cell in the row.
    # @yieldparam [TableCell] cell cell instance.
    def each
      locate
      cells.each {|cell| yield cell}
    end
    
    # @return [TableCell] cell from the row.
    # @param [Fixnum] index cell index in the row.
    # @macro exists
    def [](index)
      assert_exists
      if cells.length <= index
        raise UnknownCellException, "Unable to locate a cell at index #{index}" 
      end
      cells[index]
    end
    
    # @return [Fixnum] cells count in the row.
    # @macro exists
    def column_count
      assert_exists
      cells.length
    end

  end
  
  # Returned by {Container#td} and {Container#th}.
  class TableCell < Element
    attr_ole :headers

    alias_method :to_s, :text
    
    # @return [Fixnum] colspan attribute value.
    # @macro exists
    def colspan
      locate
      @o.colSpan
    end
  end
  
end
