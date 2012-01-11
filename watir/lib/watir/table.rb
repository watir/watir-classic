module Watir

  module RowContainer
    # Returns a row in the table
    #   * index         - the index of the row
    def [](index)
      assert_exists
      TableRow.new(self, :ole_object, @o.rows.item(index))
    end
    
    def strings
      assert_exists
      rows_memo = []
      @o.rows.each do |row|
        cells_memo = []
        row.cells.each do |cell|
          cells_memo << TableCell.new(self, :ole_object, cell).text
        end
        rows_memo << cells_memo
      end
      rows_memo
    end

  end

  # This class is used for dealing with tables.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#table method
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class Table < NonControlElement
    include RowContainer

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
      row[index].cells.length
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
        headers << TableCell.new(self, :ole_object, cell).text
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
          cells_memo[headers[j]] = TableCell.new(self, :ole_object, cell).text
          j += 1
        end

        rows_memo << cells_memo
        i += 1
      end
      rows_memo
    end
  end

  class TableSection < NonControlElement
    include RowContainer

    Watir::Container.module_eval do
      def tbody(how={}, what=nil)
        how = {how => what} if what
        TableSection.new(self, how.merge(:tag_name => "tbody"), nil)
      end

      def tbodys(how={}, what=nil)
        how = {how => what} if what
        TableSectionCollection.new(self, how.merge(:tag_name => "tbody"), nil)
      end

      def thead(how={}, what=nil)
        how = {how => what} if what
        TableSection.new(self, how.merge(:tag_name => "thead"), nil)
      end

      def theads(how={}, what=nil)
        how = {how => what} if what
        TableSectionCollection.new(self, how.merge(:tag_name => "thead"), nil)
      end

      def tfoot(how={}, what=nil)
        how = {how => what} if what
        TableSection.new(self, how.merge(:tag_name => "tfoot"), nil)
      end

      def tfoots(how={}, what=nil)
        how = {how => what} if what
        TableSectionCollection.new(self, how.merge(:tag_name => "tfoot"), nil)
      end
    end
  end

  class TableRow < NonControlElement
    TAG = "TR"
    
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
    
    # defaults all missing methods to the array of elements, to be able to
    # use the row as an array
    #        def method_missing(aSymbol, *args)
    #            return @o.send(aSymbol, *args)
    #        end
    def column_count
      locate
      cells.length
    end

    Watir::Container.module_eval do
      def row(how={}, what=nil)
        TableRow.new(self, how, what)
      end

      alias_method :tr, :row

      def rows(how={}, what=nil)
        TableRows.new(self, how, what)
      end

      alias_method :trs, :rows
    end
  end
  
  # this class is a table cell - when called via the Table object
  class TableCell < NonControlElement
    TAGS = ["TH", "TD"]

    alias to_s text
    
    def colspan
      locate
      @o.colSpan
    end
    
    Watir::Container.module_eval do
      def cell(how={}, what=nil)
        TableCell.new(self, how, what)
      end

      alias_method :td, :cell

      def cells(how={}, what=nil)
        TableCells.new(self, how, what)
      end

      alias_method :tds, :cells
    end
  end
  
end
