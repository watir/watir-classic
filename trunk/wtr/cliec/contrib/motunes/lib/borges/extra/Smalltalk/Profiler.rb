class Profiler < Component

  def child(aComponent)
    @child = aComponent
  end

  def renderContentOn(html)
    data = SeasidePlatformSupport profileSendsDuring: do
      html render: @child
    end
    html horizontalRule
    html preformatted: data
  end

end

