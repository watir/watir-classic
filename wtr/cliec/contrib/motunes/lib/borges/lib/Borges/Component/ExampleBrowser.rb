class Borges::ExampleBrowser < Borges::Component

  def all_classes
    return (Controller.all_subclasses.select do |ea|
      ea.class.selectors.anySatisfy do |s|
        s.beginsWith(self.selectorPrefix)
      end
    end).sort_by do |a| a.name end
  end

  def all_selectors
    return (@klass.class.selectors.select do |s|
      s.beginsWith(self.selectorPrefix)
    end).sort
  end

  def klass=(klass)
    @klass = klass
    self.selector = all_selectors.first
  end

  def component=(component)
    @component = component
    @has_answer = false
    @answer = nil
    @component.on_answer do |v|
      @has_answer = true
      @answer = v
    end
  end

  def initialize
    self.klass = all_classes.first
  end

  def render_content_on(r)
    r.element_id(%s'test-forms')
    r.table do
      r.table_row do
        r.table_data do
          r.form do
            r.selectFromList_selected_callback(self.allClasses, @klass,
              proc do |c| self.class(c) end)
            r.submit_button(:OK)
          end
        end

        r.table_data do
          r.form do
            r.selectFromList_selected_callback(self.allSelectors, @selector,
              proc do |s| self.selector(s) end)
            r.submit_button(:OK)
          end
        end
      end
    end

    r.horizontal_rule
    r.render(@component)

    if @has_answer then 
      r.horizontal_rule
      r.bold(%s'Answer ')
      r.text(@answer)
    end
  end

  def selector=(symbol)
    @selector = symbol
    self.component = @klass.call(@selector)
  end

  def selector_prefix
    return 'example'
  end

  register_application('examples')

end

