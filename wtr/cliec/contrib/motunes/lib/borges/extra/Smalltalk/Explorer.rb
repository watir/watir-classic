class Explorer < Component

  #attr :source # unused
  #attr :inspector # unused

  def initialize
    @tabs = StateHolder.new
  end

  def self.on(aComponent)
    return self.new.root(aComponent)
  end

  def render_content_on(r)
    r.table do
      r.tableRow do
        r.cssId('explorer-tree')
        r.tableData do
          r.render(@tree)
        end

        r.cssId('explorer-contents')
        r.tableData do
          r.render(@tabs.contents)
        end
      end
    end
  end

  def root(aComponent)
    @root = aComponent
    @tree = ComponentTree.on(@root)
    @tree.on_answer do |c| self.target(c) end
    self.target(@root)
  end

  def style
    return "#explorer-tree {
      vertical-align: top
      padding: 10px
      font-size: 10pt
      background-color: lightgrey
      width: 20%
    }
    
    #explorer-contents {
      padding: 10px
    }
    "
  end

  def target(aComponent)
    tabName = nil
    unless @tabs.contens.nil? then
      tabName = @tabs.contents.selectTabName
    end

    @tabs.contents(TabPanel.withAll([
          [:view, aComponent],
          [:source, PrettyPrinter.on(aComponent)],
          [:inspect, Inspector.on(aComponent)]))
          
    @tabs.contents.selectTabNamed(tabName) unless tabName.nil?
  end

end

