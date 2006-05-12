class Borges::HtmlResponse < Borges::Response

  def add_element(anObject)
    @stack.last.add(anObject)
  end

  def body
    return @body
  end

  def contents
    stream = ''
    print_html_on(stream)
    return stream
  end

  def head
    return @head
  end

  def initialize
    super()

    @head = Borges::HtmlElement.new('head')
    @body = Borges::HtmlElement.new('body')
    @stack = [@body]
  end

  def pop_element
    return @stack.pop
  end

  def print_html_on(str)
    str << '<html>'
    @head.print_html_on(str)
    @body.print_html_on(str)
    str << '</html>'
  end

  def push_element(anObject)
    add_element(anObject)
    @stack.push(anObject)
  end

  def render_on(html)
    root = Borges::HtmlElement.named('html')
    
    root.add(@head)
    root.add(@body)
    
    root.render_on_indent(html, 0)
  end

  def with_element_do(anElement, aBlock)
    push_element(anElement)
    aBlock.call
    pop_element
  end

end

