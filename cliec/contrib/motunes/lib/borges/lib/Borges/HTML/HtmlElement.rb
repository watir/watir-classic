class Borges::HtmlElement
  
  @@ids = []

  UNCLOSED_ELEMENTS = %w{hr br input img}

  KNOWN_ELEMENTS = %w(?xml !doctype !dt a abbr acronym address applet
      area attach b base basefont bdo big blink blockquote body br
      button caption center cite code col colgroup comment component
      dd del dfn dir div dl dt em fieldset font form frame frameset
      h h1 h2 h3 h4 h5 h6 head hr html i iframe img input ins isindex
      kbd label legend li link listing map menu meta multicol nextid
      nobr noframes noscript object ol optgroup option p param
      plaintext pre q s samp script select small span strike strong
      style sub sup table tbody td textarea textflow tfoot th thead
      title tr tt u ul var wbr xmp).map do |e| e.intern end

  attr_accessor :name

  def add(anElement)
    @children << anElement
  end

  def attribute_at_put(attr, value)
    @attributes[attr.intern] = value
  end

  ##
  # XXX refactor

  def each(&block)
    @children.each(&block)
  end

  def css_class
    if isKnownTag then
      'tag-known'
    else
      'tag-unknown'
    end
  end

  def initialize(name, attributes = nil)
    @children = []
    @name = (name.kind_of? String) ? name.downcase.intern : name
    @attributes = attributes.nil? ? Borges::HtmlAttributes.new : attributes
  end

  def is_known_tag
    return KNOWN_ELEMENTS.include?(name)
  end

  def print_close_tag_on(str)
    str << "</#{self.name}>"
  end

  def print_html_on(str)
    print_open_tag_on(str)

    each do |ea|
      ea.print_html_on(str)
    end

    print_close_tag_on(str) if should_print_close_tag
  end

  def print_open_tag_on(str)
    str << "<#{self.name}"

    @attributes.print_html_on(str)

    str << ' /' unless self.should_print_close_tag

    str << '>'
  end

  def render_close_tag_on(r)
    r.encodeText('</')
    r.span_class_with(css_class, proc do
        r.encode_text(name)
      end)
    r.encode_text('>')
  end

  def render_on_indent(r, level)
    r.break
    level.times do
      r.space
    end
    
    render_open_tag_on(r)

    each do |ea|
      ea.render_on_indent(r, level + 1)
    end

    if should_print_close_tag then
      if should_indent_close_tag then
        r.break
        level.times do r.space end
      end
      render_close_tag_on(r)
    end
  end

  def render_open_tag_on(r)
    r.encode_text('<')

    r.span_class_with(css_class, proc do
      r.encode_text(name)
    end)
    
    @attributes.render_on(r)
    
    unless should_print_close_tag then
      r.space
      r.encode_text('/')
    end

    r.encode_text('>')
  end

  def should_indent_close_tag
    return (not @children.empty?) &&
      (@children.any_satisfy do |ea| not ea.isString end)
  end

  def should_print_close_tag
    return (not UNCLOSED_ELEMENTS.include? name)
  end

end

