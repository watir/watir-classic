class Borges::TabPanel < Borges::Component

  attr_reader :tabs, :selected_tab

  def initialize(tabs = {})
    @tabs = tabs
    @selected_tab = @tabs.keys.sort.first
  end

  def render_content_on(r)
    r.table do
      r.table_row do
        render_tab_spacer_on(r)
        @tabs.sort.each do |name, tab|
          render_tab_spacer_on(r)
          render_tab(tab, name, r)
        end
      end

      r.css_class('TabLine')
      r.table_row_span(@tabs.size * 4) do
        r.text('<img width=1 height=1 alt="">')
      end
    end

    r.break

    r.render(@selected_tab)
  end

  def render_tab(tab, name, r)
    selected = tab == @selected_tab
    r.css_class(selected ? 'TabSelected' : 'TabUnselected')
    r.table_data do
      if selected then
        r.text(name)
      else
        r.anchor(name) do
          @selected_tab = tab
        end
      end
    end
  end

  def render_tab_spacer_on(r)
    r.css_class('TabSpacer')
    r.table_data do r.space end
  end

  def selected_tab=(name)
    @selected_tab = name unless @tabs[name].nil?
  end

  def style
    return "
      .TabSelected {background-color: lightblue; font-color: white; width: 95; text-align: center}
      .TabUnselected {background-color: lightgrey; width: 95; text-align: center}
      .TabSpacer {width: 15}
      .TabLine {background-color: lightblue}
    "
  end

end

