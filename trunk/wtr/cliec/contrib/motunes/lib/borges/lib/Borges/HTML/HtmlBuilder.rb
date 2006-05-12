##
# Borges::HTMLBuilder is a generic class for outputting HTML.

class Borges::HtmlBuilder

  HTML_CHARACTERS = {}

  attr_accessor :document

  attr_reader :attributes

  def bold(obj = nil, &block)
    return tag_do('b', obj) unless obj.nil?
    return tag_do('b', block)
  end

  def break
    tag('br')
  end

  def close
    @document.pop_element 
  end

  def code(obj = nil, &block)
    return tag_do('code', obj) unless obj.nil?
    return tag_do('code', block)
  end

  def css_class(class_name)
    @attributes[:class] = class_name
  end

  def div(obj = nil, &block)
    return tag_do('div', obj) unless obj.nil?
    return tag_do('div', block)
  end

  def div_named(name, obj = nil, &block)
    element_id(name)
    div(obj, &block)
  end

  def div_with_class(class_name, obj = nil, &block)
    css_class(class_name)
    div(obj, &block)
  end

  def element_id(e_id)
    @attributes['id'] = e_id
  end

  def encode_char(char)
    @document.add_element("&##{char.to_i};")
  end

  ##
  # Turn an object into a string and encode it with HTML entities.
  #
  # encode_text("foo > bar")
  #
  # foo &gt; bar

  def encode_text(obj)
    encoded = ""

    obj.to_s.each_byte do |char|
      e = HTML_CHARACTERS[char]
      encoded << (e.nil? ? char.chr : e.to_s)
    end

    text(encoded)
  end

  def head_tag(name)
    element = Borges::HtmlElement.new(name, @attributes)
    @document.head.add(element)
    @attributes = Borges::HtmlAttributes.new
    return element
  end

  def head_tag_with(str, child)
    head_tag(str).add(child)
  end

  ##
  # Create a level 1 heading
  #
  # heading("My Heading")
  #
  # <h1>My Heading</h1>

  def heading(str)
    heading_level(str, 1)
  end

  ##
  # Create a heading with level
  #
  # heading_level("My Heading", 2)
  #
  # <h2>My Heading</h2>

  def heading_level(obj, level)
    tag_do("h#{level}", obj)
  end

  def horizontal_rule
    tag('hr')
  end

  def initialize
    @attributes = Borges::HtmlAttributes.new
  end

  def input(input_type, name = nil, value = nil)
    unless name.nil? then
      @attributes['name'] = name
    end

    unless value.nil? then
      @attributes['value'] = value
    end
      
    @attributes['type'] = input_type
    
    tag('input')
  end

  def italic(obj = nil, &block)
    return tag_do('i', obj) unless obj.nil?
    return tag_do('i', block)
  end

  ##
  # Build an unordered list of items from an Enumerable.  #text will be called
  # on each item.
  # 
  # list(["x", 5, { :x => :y }])
  # 
  # <ul><li>x<li>5<li>xy</ul>

  def list(items)
    list_do(items) do |x| text(x) end
  end

  ##
  # Build an unordered list of items from an Enumerable.  The given block will
  # be called on each item.
  #
  # See also #list

  def list_do(items, &block)
    tag_do('ul', proc do
      items.each do |item|
        tag_do('li', proc do block.call(item) end)
      end
    end)
  end

  def open_tag(name)
    @document.push_element(Borges::HtmlElement.new(name.intern, @attributes))
    @attributes = Borges::HtmlAttributes.new
  end

  def paragraph(obj = nil, &block)
    return tag_do('p', obj) unless obj.nil?
    return tag('p') if block.nil?
    return tag_do('p', block)
  end

  def preformatted(obj = nil, &block)
    return tag_do('pre', obj) unless obj.nil?
    return tag_do('pre', block)
  end

  def render(obj)
    raise "Rendering nil object" if obj.nil? # XXX catch possible bugs
    obj.render_on(self)
  end

  def set_attribute(attr, val)
    @attributes[attr] = val

    return val
  end

  def small(&block)
    tag_do('small', block)
  end

  def space
    text('&nbsp;')
  end

  def style_link(url)
    @attributes['rel'] = 'stylesheet'
    @attributes['type'] = 'text/css'
    @attributes['href'] = url
    head_tag('link')
  end

  ##
  # Create a table element

  def table(&block)
    tag_do('table', block)
  end

  ##
  # Create a table cell

  def table_data(obj = nil, &block)
    return tag_do('td', obj) unless obj.nil?
    return tag_do('td', block)
  end

  ##
  # Create a table header cell

  def table_heading(obj = nil, &block)
    return tag_do('th', obj) unless obj.nil?
    return tag_do('th', block)
  end

  ##
  # Create a table heading row

  def table_headings(*headings)
    table_row do
      headings.each do |heading|
        table_heading(heading)
      end
    end
  end

  ##
  # Create an empty table row

  def table_row(&block)
    tag_do('tr', block)
  end

  ##
  # Create a table row that spans multiple columns

  def table_row_span(span, &block)
    table_row do
      @attributes['colspan'] = span
      table_data(&block)
    end
  end

  ##
  # Create a table row containing a single data cell

  def table_row_with(obj = nil, &block)
    table_row do table_data(obj || block) end
  end

  def table_row_labeled(label, obj = nil, &block)
    table_row do
      css_class('label')
      table_data(label)
      table_data(obj, &block)
    end
  end

  def table_spacer_row
    table_row do space end
  end

  def tag(str)
    open_tag(str)
    close
  end

  def tag_do(name, obj)
    open_tag(name)
    render(obj)
    close
  end

  ##
  # Turn an object into a string.  It is _not_ recommened to use this method
  # to dump raw HTML.
  #
  # text("hello world")
  #
  # hello world

  def text(obj)
    @document.add_element(obj.to_s)
  end

  def title(str)
    head_tag_with('title', str)
  end

  def url_anchor(url, obj = nil, &block)
    @attributes['href'] = url
    return tag_do('a', obj) unless obj.nil?
    return tag_do('a', block)
  end

=begin
  def anchorWithUrl_title_do(urlString, titleString, &block)
    attributes.title(titleString)
    anchorWithUrl_do(urlString, &block)
  end

  ##
  # XXX Same as Hash#update

  def attributes=(attrs)
    @attributes ||= Borges::HtmlAttributes.new

    attrs.each do |key, val|
      @attributes[key] = val
    end
  end

  def buttonForUrl_withText(urlString, labelString)
    buttonForUrl_withText_data(urlString, labelString, [])
  end

  def buttonForUrl_withText_data(urlString, labelString, assocCollection)
    formWithMethod_action_do('GET', urlString, proc do

      assocCollection.each do |each|
        inputWithType_named_value('hidden', each.key, each.value)
      end

      submitButtonWithText(labelString)
    end)
  end

  def doesNotUnderstand(aMessage)
    argCount = aMessage.arguments.size
    if argCount == 0 then
      return tag(aMessage.selector)
    end

    if argCount == 1 then
      return tag_do(aMessage.selector.allButLast, aMessage.argument)
    end

    return super.doesNotUnderstand(aMessage)
  end

  def emphasis(&block)
    tag_do('em', block.call)
  end

  def formWithAction_do(actionUrl, &block)
    formWithMethod_action_do('POST', actionUrl, &block)
  end

  def formWithMethod_action_do(methodString, actionUrl, &block)
    attributes.method(methodString)
    attributes.action(actionUrl)
    openTag('form')
    block.call
    close
  end

  ##
  # HTML4 image must have alt attribute

  def image(urlString)
    attributeAt_put('src', urlString)
    
    tag('img')
  end

  def image_altText(urlString, altString)
    attributeAt_put('alt', altString)
    
    image(urlString)
  end

  def image_width_height(urlString, width, height)
    attributeAt_put('width', width)
    attributeAt_put('height', height)
    
    image(urlString)
  end

  def image_width_height_altText(urlString, width, height, altString)
    attributeAt_put('alt', altString)
    
    image_width_height(urlString, width, height)
  end

  def inputWithType(input_type)
    inputWithType_named(input_type, nil)
  end

  def inputWithType_named(input_type, name)
    inputWithType_named_value(input_type, name, nil)
  end

  def layoutTable(&block)
    attributes.border(0)
    attributes.cellspacing(0)
    attributes.cellpadding(0)
    table(&block)
  end

  def layoutTableOfWidth_do(width, &block)
    attributes.width(width)
    layoutTable(&block)
  end

  def metaTagNamed_content(nameString, contentString)
    attributes.name(nameString)
    attributes.content(contentString)
    headTag('meta')
  end

  def self.on(aDocument)
    inst = self.new
    inst.document = aDocument
    return inst
  end

  def scriptWithUrl(urlString)
    attributes.language('javascript')
    attributes.src(urlString)
    headTag('script')
  end

  def span(&block)
    tag_do('span', block.call)
  end

  def spanClass_with(aString, anObject)
      cssClass(aString)
      span(anObject)
  end

  def spanNamed_with(aString, anObject)
    cssId(aString)
    span(anObject)
  end

  def submitButton
    inputWithType('submit')
  end

  def submitButtonWithText(aString)
    attributes.value(aString)
    inputWithType('submit')
  end

  def tableRowWith(&block)
    tableRow do
      tableData(&block)
    end
  end

  def tableRowWith_with(aBlock, anotherBlock)
    tableRow do
      tableData(aBlock)
      tableData(anotherBlock)
    end
  end

  def tableRowWith_with_with(x, y, z)
    tableRow do
      tableData(x)
      tableData(y)
      tableData(z)
    end
  end

  def tableRowWithLabel_column_column(anObject, aBlock, anotherBlock)
    tableRow do
      cssClass('label')
      tableData(anObject)
      tableData(aBlock)
      tableData(anotherBlock)
    end
  end

  def underline(&block)
    tag_do('u', block.call)
  end
=end

  ##
  # HtmlBuilder initialize

  {'quot' => '"', 'lt' => '<', 'amp' => '&', 'gt' => '>'}.each do |s, c|
    HTML_CHARACTERS[c[0]] = "&#{s};"
  end

  %w(nbsp iexcl cent pound curren yen brvbar sect uml copy ordf
    laquo not shy reg hibar deg plusmn sup2 sup3 acute micro para
    middot cedil sup1 ordm raquo frac14 frac12 frac34 iquest
    Agrave Aacute Acirc Atilde Auml Aring AElig Ccedil Egrave
    Eacute Ecirc Euml Igrave Iacute Icirc Iuml ETH Ntilde Ograve
    Oacute Ocirc Otilde Ouml times Oslash Ugrave Uacute Ucirc
    Uuml Yacute THORN szlig agrave aacute acirc atilde auml aring
    aelig ccedil egrave eacute ecirc euml igrave iacute icirc
    iuml eth ntilde ograve oacute ocirc otilde ouml divide oslash
    ugrave uacute ucirc uuml yacute thorn yuml).each_with_index do |s, i|
      HTML_CHARACTERS[(i - 1 + 160)] = "&#{s};"
  end

end

