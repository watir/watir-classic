class InputTest < Borges::Component

  attr_accessor :nil_string, :empty_string, :integer, :fraction

  def initialize
    @nil_string = nil
    @empty_string = ''
    @integer = 42
    @fraction = 1/3.0
  end

  def render_content_on(r)
    r.form do
      r.table do
        r.table_headings(%w(Name Value PrintString))

        r.table_row do
          r.table_heading('Nil String')

          r.table_data do
            r.text_input_on(:nil_string, self)
          end

          r.table_data do
            r.text(@nil_string)
          end
        end

        r.table_row do
          r.table_heading('Empty String')

          r.table_data do
            r.text_input_on(:empty_string, self)
          end

          r.table_data do
            r.text(@empty_string)
          end
        end

        r.table_row do
          r.table_heading('Integer')

          r.table_data do
            r.text_input_on(:integer, self)
          end

          r.table_data do
            r.text(@integer)
          end
        end

        r.table_row do
          r.table_heading('Fraction')

          r.table_data do
            r.text_input_on(:fraction, self)
          end

          r.table_data do
            r.text(@fraction)
          end
        end

        r.submit_button do end
      end
    end
  end

end

