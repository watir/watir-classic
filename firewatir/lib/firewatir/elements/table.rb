module FireWatir
  class Table < Element
    attr_accessor :element_name
    TAG = 'TABLE'

    #   - how - Attribute to identify the table element.
    #   - what - Value of that attribute.
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
      @o = nil
      #super nil
    end

    #
    # Description:
    #   Locate the table element.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('TABLE', @how, @what)
      end
      @o = self
    end

    #
    # Description:
    #   Override the highlight method, as if the tables rows are set to have a background color,
    #   this will override the table background color,  and the normal flash method wont work
    #
    def highlight(set_or_clear )

      if set_or_clear == :set
        begin
          @original_border = @o.border.to_i
          if @o.border.to_i==1
            @o.border = 2
          else
            @o.border=1
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

    #
    # Description:
    #   Used to populate the properties in the to_s method.
    #
    #def table_string_creator
    #    n = []
    #    n <<   "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
    #    n <<   "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
    #    return n
    #end
    #private :table_string_creator

    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    # TODO: Implement to_s method for this class.

    def to_s
      assert_exists
      r = super({"rows" => "rows.length","columns" => "columnLength", "cellspacing" => "cellspacing", "cellpadding" => "cellpadding", "border" => "border"})
      # r += self.column_count.to_s
    end

    #
    # Description:
    #   Gets the number of rows in the table.
    #
    # Output:
    #   Number of rows.
    #
    def row_count
      assert_exists
      return rows.length
    end

    #
    # Description:
    #   Gets the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
    #
    # Output:
    #   2D array with rows and column text of the table.
    #
    def to_a
      assert_exists
      y = []
      table_rows = rows
      for row in table_rows
        x = []
        row.each do |td|
          x << td.to_s.strip
        end
        y << x
      end
      return y
    end

    #
    # Description:
    #   Gets the array of rows in the table.
    #
    # Output:
    #   Array of rows.
    #
    def rows
      assert_exists
      arr_rows = get_rows
      table_rows = Array.new(arr_rows.length)
      for i in 0..arr_rows.length - 1 do
        table_rows[i] = TableRow.new(@container, :jssh_name, arr_rows[i])
      end
      return table_rows
    end

    #
    # Description:
    #   Get row at particular index in table.
    #
    # Input:
    #   key - row index
    #
    # Output:
    #   Table Row element
    #
    def [](key)
      assert_exists
      arr_rows = rows
      return arr_rows[key - 1]
    end

    #
    # Desription:
    #   Iterate over each table row element.
    #
    def each
      assert_exists
      arr_rows = rows
      for i in 0..arr_rows.length - 1 do
        yield arr_rows[i]
      end
    end

    #
    # Description:
    #   Get column count of first row in the table.
    #
    # Output:
    #   Number of columns in first row.
    #
    def column_count
      assert_exists
      arr_rows = rows
      return arr_rows[0].column_count
    end

    #
    # Description:
    #   Get values of specified column in each row.
    #
    # Input:
    #   Column number
    #
    # Output:
    #   Values of column (specified as input) in each row
    #
    def column_values(column)
      assert_exists
      arr_rows = rows
      values = Array.new(arr_rows.length)
      for i in 0..arr_rows.length - 1 do
        values[i] = arr_rows[i][column].to_s
      end
      return values
    end

    #
    # Description:
    #   Get values of all the column in specified row.
    #
    # Input:
    #   Row number.
    #
    # Output:
    #   Value of all columns present in the row.
    #
    def row_values(row)
      assert_exists
      arr_rows = rows
      cells = arr_rows[row - 1].cells
      values = Array.new(cells.length)
      for i in 0..cells.length - 1 do
        values[i] = cells[i].to_s
      end
      return values
    end

  end # Table
end # FireWatir
