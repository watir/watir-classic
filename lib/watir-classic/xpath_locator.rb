module Watir
  # @private
  module XpathLocator

    def xmlparser_document_object
      @xml_parser_doc ||= begin
                            require 'nokogiri'
                            Nokogiri.parse("<html>#{@container.html}</html>")
                          end
    end

    # execute css selector and return an array of elements
    def elements_by_css(selector)
      xmlparser_document_object # Needed to ensure Nokogiri has been loaded
      xpath = Nokogiri::CSS.xpath_for(selector)[0]
      elements_by_xpath(xpath)
    end

    # return the first element that matches the css selector
    def element_by_css(selector)
      elements_by_css(selector)[0]
    end

    # return the first element that matches the xpath
    def element_by_xpath(xpath)
      elements_by_xpath(xpath)[0]
    end

    # execute xpath selector and return an array of elements
    def elements_by_xpath(xpath)
      doc = xmlparser_document_object
      current_tag = @container.is_a?(IE) ? "body" : @container.tag_name

      doc.xpath(xpath).reduce([]) do |elements, element|
        absolute_xpath_parts = element.path.split("/")
        first_tag_position = absolute_xpath_parts.index(current_tag) || absolute_xpath_parts.index("html") + 1
        element_xpath_parts = absolute_xpath_parts[first_tag_position..-1]
        elements << element_xpath_parts.reduce(@container.page_container) do |container, tag|
          tag_name, index = tag.split(/[\[\]]/)
          index = index ? index.to_i - 1 : 0
          specifiers = {:tag_name => [tag_name]}
          direct_children(container, container.send(:elements, specifiers))[index]
        end.ole_object
      end
    end    

    def direct_children container, elements
      return elements if container.is_a?(IE)
      elements.select {|el| el.parent == container}
    end

  end
end
