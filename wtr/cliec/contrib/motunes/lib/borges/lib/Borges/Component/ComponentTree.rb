class Borges::ComponentTree < Borges::Component

  def self.on(component)
    return self.new.root(component)
  end

  def render_branch_named_on(component, name, r)
    return self if @components.include? component

    r.li do
      render_link_named_on(component, name, r)
      render_tree_on(component, r)
    end
  end

  def render_children_of_on(component, r)
    r.ul do 
      component.class.instance_variables.each do |name|
        ivar = component.get_instance_variable(name)
        if ivar.kind_of? Controller then
          render_branch_named_on(ivar, name, r)

        else
          if ivar.respond_to?(:each) && ivar.respond_to?(%s'all?') &&
            ivar.all? do |ea| ea.kind_of? Component end then
            render_collection_named_on(ivar, name, r)
          end
        end
      end
    end
  end

  def render_collection_named_on(collection, name, r)
    r.li do
      r.text(name)
      r.ol do
        collection.each do |ea|
          r.li do
            render_tree_on(ea, r)
          end
        end
      end
    end
  end

  def render_content_on(r)
    @components = Set.new
    render_link_named_on(@root, 'root', r)
    render_tree_on(@root, r)
  end

  def render_link_named_on(component, name, r)
    if component == self.selection then
      r.bold do
        r.anchor(name) do
          @selection.contents = component
          answer(component.active_controller)
        end
      end
    else
      r.anchor(name) do
        @selection.contents = component
        answer(component.active_controller)
      end
    end
  end

  def render_tree_on(component, r)
    unless @components.include? component then
      @components << component
      render_children_of_on(component.active_controller, r)
    end
  end

  def root(component)
    @root = component
    @selection = StateHolder.new(@root)
  end

  def selection
    return @selection.contents
  end

end

