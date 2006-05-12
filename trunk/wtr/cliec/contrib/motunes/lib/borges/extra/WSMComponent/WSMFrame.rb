class WSMFrame < Component

  def home()
    @main clearDelegate
  end

  def homeClass()
    return WSMIndex
  end

  def initialize()
    @main = self.homeClass.new
  end

  def isHome()
    return @main activeController class = self.homeClass
  end

  def performAction(aSymbol)
    @main activeController perform: aSymbol
  end

  def renderContentOn(html)
    html divNamed: 'nav' with: do self.renderNavigationOn: html end
    html divNamed: 'main' with: @main
  end

  def renderNavigationOn(html)
    html heading: 'SqueakMap Browser' level: 3

    html divNamed: 'actions' with: do
      self.isHome ifFalse: do
        html anchorWithAction: do self.home end text: 'Home'
        html paragraph
      end

      if (@main activeController respondsTo: :actions) then
        @main activeController actions pairsDo: do |description selector|
          html anchorWithAction: do self.performAction: selector end text: description
          html break
        end
      end
    end
  end

  def style()
    return '/*/*/
    #main {
      float: left
      width: 70%
      padding: 2%
    }

    #nav {
      float: left
      width: 20%
      padding: 2%
    }
    '
  end

  self.registerAsApplication: 'sm'

end

