class Borges::HtmlAttributes

  KNOWN_ATTRIBUTES = %w(abbr accept-charset accept accesskey action align
  alink alt archive axis background bgcolor bgproperties border
  cellpadding cellspacing char charoff charset checked cite
  class classid clear code codebase codetype color cols colspan
  compact content coords data datetime declare defer dir direction
  disabled encoding enctype face for frame frameborder framespacing
  gutter headers height href hreflang hspace http-equiv id ismap
  label lang leftmargin link longdesc loop lowsrc marginheight
  marginwidth maxlength media method methods multiple name
  nohref noresize noshade nowrap object onabort onblur onchange
  onclick ondblclick onerror onfocus onkeydown onkeypress onkeyup
  onload onmousedown onmousemove onmouseout onmouseover onmouseup
  onreset onselect onsubmit onunload prompt PUBLIC readonly rel
  rev rows rowspan rules scheme scope scrolling selected shape
  size span src standby style summary tabindex target text title
  type urn usemap valign value valuetype version vlink vspace
  width wrap xml:lang xmlns)#.map do |i| i.intern end

  def initialize
    @attributes = {}
  end

  def align_center
    self[:align] = :center
  end

  def []=(attr, value)
    @attributes[attr] = value
  end

  def css_class_for_attribute(attr)
    if is_known_attribute(attr) then
      'attribute-known' 
    else
      'attribute-unknown'
    end
  end

  def method_missing(mesg, *a)
    arg_count = a.length 
    if arg_count == 0 then
      return self[mesg] = true
    elsif arg_count == 1 then
      return self[mesg] = a[0]
    end

    return super
  end

  def is_known_attribute(attr)
    return KNOWN_ATTRIBUTES.include?(attr.downcase.intern)
  end

  def print_attribute_on(attr, val, str)
    return if val == false

    attr = attr.to_s.downcase
    str << " #{attr}=\"#{val == true ? attr : val}\""
  end

  def print_html_on(str)
    @attributes.each do |attr, val|
      print_attribute_on(attr, val, str)
    end
  end

  def render_attribute_on(assoc, r)
    attr = assoc.key.lowercase
    value = assoc.value

    unless value == false then
      r.space

      r.span_class_with(self.css_class_for_attribute(attr), proc do
        r.encode_text(attr)
      end)

      r.encode_text('=')

      r.span_class_with('attribute-value', proc do
        r.encode_text('"')
        unless value == true then
          r.encode_text(value.to_s)

        else
          r.encode_text(attr)

        end

        r.encode_text('"')
      end)
    end
  end

  def render_on(r)
    unless @attributes.nil? then
      @attributes.each do |assoc|
        self.render_attribute_on(assoc, r)
      end
    end
  end

end

