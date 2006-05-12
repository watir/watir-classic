class Borges::PluggableSelectBox

  attr_accessor :change_seleced, :list, :model, :selected, :size

  def initialize(model, list, selected, change_selected, size = 10)
    @model = model
    @list = list
    @selected = selected
    @change_selected = change_selected
    @size = size
  end

  def render_on(r)
    array = @model.call(@list).to_a

    r.div_class_with('column-choice') do
      r.form do
        r.attributes[:size] = @size
        r.attributes[:onChange] = 'submit()'
        r.select_from_list_selected_callback(array,
          array[@model.send(@selected)]) do |item|
            @model.send(@change_selected, array.index(item))
          end
      end
    end
  end

end

