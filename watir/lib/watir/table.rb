module Watir

  module TableContainer
    # Returns a row in the table
    #   * index         - the index of the row
    def [](index)
      assert_exists
      TableRow.new(self, :ole_object => @o.rows.item(index))
    end
    
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
    def table_elements(klass, tags, how, what, ole_collection)
      specifiers = format_specifiers(tags, how, what)
      klass.new(self, specifiers, ole_collection)
    end

    private :table_elements
  end

  module TableCellsContainer
    include TableElementsContainer

    def cells(how={}, what=nil)
      assert_exists
      table_elements(TableCellCollection, [:th, :td], how, what, @o.cells)
    end

    def cell(how={}, what=nil)
      specifiers = format_specifiers([:th, :td], how, what)
      index = specifiers.delete(:index) || 0
      cells(specifiers)[index]
    end
  end

  module TableRowsContainer
    include TableElementsContainer

    def rows(how={}, what=nil)
      assert_exists
      table_elements(TableRowCollection, [:tr], how, what, @o.rows)
    end

    def row(how={}, what=nil)
      specifiers = format_specifiers([:tr], how, what)
      index = specifiers.delete(:index) || 0
      rows(specifiers)[index]
    end
  end

  # This class is used for dealing with tables.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#table method
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class Table < Element
    include TableContainer
    include TableRowsContainer
    include TableCellsContainer

    attr_ole :rules

    # override the highlight method, as if the tables rows are set to have a background color,
    # this will override the table background color, and the normal flash method won't work
    def highlight(set_or_clear)
      if set_or_clear == :set
        begin
          @original_border = @o.border.to_i
          if @o.border.to_i==1
            @o.border = 2
          else
            @o.border = 1
          end
        rescue
          @original_border = nil
        end
      else
        begin
          @o.border= @original_border unless @original_border == nil
          @original_border = nil
        rescue
          # we could be here for a number of reasons...
        ensure
          @original_border = nil
        end
      end
      super
    end
    
    # this method is used to populate the properties in the to_s method
    def table_string_creator
      n = []
      n << "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
      n << "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
      return n
    end
    private :table_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    def to_s
      assert_exists
      r = string_creator
      r += table_string_creator
      return r.join("\n")
    end
    
    # iterates through the rows in the table. Yields a TableRow object
    def each
      assert_exists
      @o.rows.each do |row| 
        yield TableRow.new(self, :ole_object, row)
      end
    end
    
    # Returns the number of rows inside the table, including rows in nested tables.
    def row_count
      assert_exists
      rows.length
    end

    # This method returns the number of columns in a row of the table.
    # Raises an UnknownObjectException if the table doesn't exist.
    #   * index         - the index of the row
    def column_count(index=0)
      assert_exists
      rows[index].cells.length
    end
    
    # Returns an array containing all the text values in the specified column
    # Raises an UnknownCellException if the specified column does not exist in every
    # Raises an UnknownObjectException if the table doesn't exist.
    # row of the table
    #   * columnnumber  - column index to extract values from
    def column_values(columnnumber)
      return (0..row_count - 1).collect {|i| self[i][columnnumber].text}
    end
    
    # Returns an array containing all the text values in the specified row
    # Raises an UnknownObjectException if the table doesn't exist.
    #   * rownumber  - row index to extract values from
    def row_values(rownumber)
      return (0..column_count(rownumber) - 1).collect {|i| self[rownumber][i].text}
    end
    
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
  end

  class TableSection < Element
    include TableContainer
    include TableRowsContainer
    include TableCellsContainer
  end

  class TableRow < Element
    include TableCellsContainer

    # this method iterates through each of the cells in the row. Yields a TableCell object
    def each
      locate
      cells.each {|cell| yield cell}
    end
    
    # Returns an element from the row as a TableCell object
    def [](index)
      assert_exists
      if cells.length <= index
        raise UnknownCellException, "Unable to locate a cell at index #{index}" 
      end
      return cells[index]
    end
    
    def column_count
      assert_exists
      cells.length
    end

  end
  
  # this class is a table cell - when called via the Table object
  class TableCell < Element
    attr_ole :headers

    alias_method :to_s, :text
    
    def colspan
      locate
      @o.colSpan
    end
  end
  
end
