# $Id$
=begin
--------------------------------------------------------------------------
Copyright (c) 2001-2004, Chris Morris All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. Neither the names Chris Morris, cLabs nor the names of contributors to
this software may be used to endorse or promote products derived from this
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
=end

require 'win32ole'

# http://msdn.microsoft.com/workshop/browser/webbrowser/reference/Objects/InternetExplorer.asp

module CLabs
  module IEC
    # VERSION auto generated section
    begin                                                                  
      require 'cl/util/version'                                            
      VERSION = CLabs::Version.new('2004', '227', '0')
    rescue LoadError                                                       
      VERSION = '2004.227.0'                                                  
    end                                                                    
    # END_VERSION

    class ClIEController
      attr_reader :ie, :options
      attr_accessor :auto_wrap_form

      READYSTATE_UNINITIALIZED = 0
      READYSTATE_LOADING = 1
      READYSTATE_LOADED = 2
      READYSTATE_INTERACTIVE = 3
      READYSTATE_COMPLETE = 4

      @@closed_last = nil
      
      def initialize(options = {})
        # creating a new IE instance immediately after quiting a previous one
        # causes intermittent RPC unavailable errors and other weirdness.
        # Make sure to wait 1 second after eating before swimming...
        until (Time.now - @@closed_last) > 1; sleep 0.1; end if @@closed_last
        
        @ie = WIN32OLE.new('InternetExplorer.Application')
        if ((options.is_a? TrueClass) || (options.is_a? FalseClass))
          # backward compatibility
          @ie.visible = options
        else
          @options = options.dup
          @ie.visible = (@options[:visible] == true)
          @auto_wrap_form = (@options[:auto_wrap_form] == true)
        end
      end

      def close
        @@closed_last = Time.now
        @ie.quit
      end

      def form(index = 0, wrap = false)
        f = @ie.document.forms(index)
        f = IEDomFormWrapper.new(f) if wrap || @auto_wrap_form
        f
      end

      def ClIEController.get_active_element_name(activeElement)
        begin
          activeElement.name
        rescue
          'unknown'
          # if the focus is not on a form control, name is an invalid prop
          # even though activeElement is a valid object of some sort
        end
      end

      def active_element
        ClIEController.get_active_element_name @ie.document.activeElement
      end
      alias activeElement active_element

      @@wrap_classes = []
      def ClIEController.wrap_classes
        @@wrap_classes
      end
      
      def ClIEController.wrap_node(node)
        wrapped_node = nil
        @@wrap_classes.each do |cls|
          # form inputs all have the same tagName (INPUT), but 'type' 
          # defines which type of input node it is.
          # <a...> tags, however, have a type of "", so you must go with
          # tagName. <h#> tags don't even have a property called type, so
          # it errors out.
          node_type = node.invoke('tagName') 
          node_type = node.invoke('type') if node_type =~ /input/i
          if node_type =~ cls.wrap_type_re 
            wrapped_node = cls.new(node)
            break
          end
        end
        wrapped_node = IEDomNodeWrapper.new(node) if wrapped_node.nil?
        wrapped_node
      end
      
      # perhaps a refactoring is in order with GUIFormWrapper.method_missing
      def method_missing(methID, *args, &block)
        # if we're not in this state, then there's probably not a page loaded,
        # and trying to work with the DOM raises an exception.
        if (@ie.readyState == ClIEController::READYSTATE_COMPLETE)
          method = methID.id2name
          node = @ie.document.all(method.chop_setter)
          if node
            node = ClIEController.wrap_node(node)
            if @options[:demo_mode]
              node.highlight 
              demo_wait
              node.un_highlight
            end
            res = node.send(node.default_attribute(method[-1..-1] == '='), *args)
            wait
            res
          else
            @ie.send(methID, *args, &block)
          end
        else
          @ie.send(methID, *args, &block)
        end
      end

      def navigate(href)
        @ie.navigate(href)
        waitForIE
      end

      def hide
        @ie.visible = false
      end

      def htmlNode
        @ie.document.childNodes.length.times do |i|
          if @ie.document.childNodes(i).nodeName == 'HTML'
            return @ie.document.childNodes(i)
            break
          end
        end
      end

      def show
        @ie.visible = true
      end

      def submit
        form.submit
        wait
      end
      
      def wait
        waitForIE
      end

      def waitForIE
        # busy seems to return control too soon, but going
        # direct to another check of readyState is too fast,
        # browser can still be in READYSTATE_COMPLETE
        while @ie.busy
          sleep 0.01
        end

        until @ie.readyState == READYSTATE_COMPLETE
          sleep 0.01
        end
      end
      
      def demo_wait  
        sleep @options[:demo_wait] if @options[:demo_mode]
      end
      
      def dump_dom(io=$stdout)
        dv = ClIEDomViewer.new(self)
        dv.outputDom(io)
      end
    end

    class ClIEDomViewer
      def initialize(aIEController)
        @iec = aIEController
      end

      def htmlRootNode
        ClDomNodeWrapper.new(@iec.htmlNode, 'HTML')
      end

      def outputDom(io=$stdout)
        rootNodeWrapper = htmlRootNode
        buildNodeWrapperTree(rootNodeWrapper)
        dumpWrapperNode(rootNodeWrapper, "-", io)
      end

      def buildNodeWrapperTree(rootNodeWrapper)
        p rootNodeWrapper if $debug
        rootNodeWrapper.node.childNodes.length.times do |i|
          buildNodeWrapperTree(rootNodeWrapper.addChild(rootNodeWrapper.node.childNodes(i)))
        end
      end

      def dumpWrapperNode(aNode, path, io=$stdout)
        io.puts 'nodeName: ' + path + aNode.name
        io.puts 'nodeValue: ' + aNode.node.nodeValue if !aNode.node.nodeValue.nil?
        # p 'outerText: ' + aNode.outerText if !aNode.outerText.nil?
        aNode.childArray.each do | childNodeWrapper |
          dumpWrapperNode(childNodeWrapper, path + aNode.name + "-", io)
        end
      end

      def getNodeWrapperFromPath(path, rootNodeWrapper)
        pathParts = path.split('-')
        pathParts.delete_at(0) if pathParts[0] == 'HTML'
        nodeWrapper = rootNodeWrapper
        pathParts.each do | nodeWrapperName |
          nodeWrapper.childArray.each do | childNodeWrapper |
            if childNodeWrapper.name == nodeWrapperName
              nodeWrapper = childNodeWrapper
              break
            end
          end
        end
        return nodeWrapper
      end
    end

    # this class and IEDomNodeWrapper have something in common, eh?
    class ClDomNodeWrapper
      attr_accessor :name
      attr_reader :node, :childArray

      def initialize(aNode, name = '')
        @node = aNode
        @name = name
        @childArray = Array.new
      end

      def addChild(childNode)
        p childNode if $debug
        newWrapperNode = ClDomNodeWrapper.new(childNode, getChildName(childNode))
        @childArray << newWrapperNode
        newWrapperNode
      end

      def getChildName(childNode)
        inc = 1
        @childArray.each do | childNodeWrapper |
          # this may seem a little unnecessary, assigning to two
          # local variables first, but it works around a segfault
          # in win32ole 0.5.2, ruby 1.8p3, win2k
          childNodeWrapperNodeName = childNodeWrapper.node.nodeName
          childNodeNodeName = childNode.nodeName
          inc = inc + 1 if childNodeWrapperNodeName == childNodeNodeName
        end
        return childNode.nodeName + inc.to_s
      end

      def value
        @node.nodeValue
      end
    end

    # this doesn't belong here, inside IEC module, since WindowsForm 
    # descends from it
    class GUIFormWrapper
      attr_reader :form
     
      def initialize(form)
        @form = form
      end

      def methodIsSetter(methodName)
        return methodName[-1, 1] == '='
      end

      # seems a refactoring is in order with ClIEController.method_missing
      def method_missing(methID, *args)
        methodName = methID.id2name
        setter = methodIsSetter(methodName)
        methodName.chop! if setter
        if methodIsFormNode(methodName)
          sendToFormNode(methodName, setter, *args)
        else
          @form.send(methID, *args)
        end
      end

      def methodIsFormField(methodName)
        raise "abstract method methodIsFormField in GUIFormWrapper"
      end

      def sendToFormNode(methodName, setter, *args)
        raise 'abstract'
      end
      alias sendToFormField sendToFormNode # backward compat
    end

    class IEDomFormWrapper < GUIFormWrapper
      def sendToFormNode(methodName, setter, *args)
        @field = get_node_wrapper(methodName) 
        @field.send(@field.default_attribute(setter), *args)
      end
      
      def get_node_wrapper(node_name)
        node = ClIEController.wrap_node(@form.all(node_name))
      end
    
      def methodIsFormNode(methodName)
        return @form.all(methodName) != nil
      end
      alias methodIsFormElement methodIsFormNode # backwards compat
      alias methodIsFormField methodIsFormNode   # backwards compat

      def active_element
        ClIEController.get_active_element_name(@form.ownerDocument.activeElement)
      end
      alias activeElement active_element
    end

    # All IE DOM nodes are either nodeType 1 (element)
    # or nodeType 3 (text) 
    # see:
    #   http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/nodetype.asp]
    #   http://msdn.microsoft.com/workshop/author/dhtml/reference/collections/elements.asp]
    
    # this class and ClDomNodeWrapper have something in common, eh?
    class IEDomNodeWrapper
      ClIEController.wrap_classes << self
      def self.inherited(sub_class)
        ClIEController.wrap_classes << sub_class
      end 
    
      def IEDomNodeWrapper.wrap_type_re
        nil
      end
    
      def default_attribute(is_setter)
        result = @default_attribute
        if is_setter
          raise 'node is read-only' if @read_only 
          result << '=' 
        end
        result
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'value'
      end
      
      def method_missing(methID, *args, &block)
        @node.send(methID, *args, &block)
      end
      
      def highlight
        @orig_color = @node.style.color
        @orig_border = @node.style.border
        @node.style.color = 'red'
        @node.style.border = '2px solid red'
        @node.focus
      end
      
      def un_highlight
        @node.style.color = @orig_color if @orig_color
        @node.style.border = @orig_border if @orig_border
      end
    end
    
    class IEDomCheckboxWrapper < IEDomNodeWrapper
      def IEDomCheckboxWrapper.wrap_type_re
        /checkbox/i    
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'checked'
      end
    end
    
    class IEDomSelectWrapper < IEDomNodeWrapper
      def IEDomSelectWrapper.wrap_type_re
        /select/i
      end
    
      def initialize(selectElement)
        @select = selectElement
        @node = @select
        @default_attribute = 'value'
      end

      def value=(aValue)
        @select.options.each do |opt|
          opt.selected = true if opt.text == aValue
        end
      end

      def value
        selected = nil
        @select.options.each do |opt|
          selected = opt if opt.selected
        end
        if !selected.nil?
          selected.text
        else
          ''
        end
      end
    end
    
    class IEDomAWrapper < IEDomNodeWrapper
      def IEDomAWrapper.wrap_type_re
        /\Aa\z/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'click'
      end
    end
    
    class IEDomSpanWrapper < IEDomNodeWrapper
      def IEDomSpanWrapper.wrap_type_re
        /span/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'innerText'
        @read_only = true
      end
    end
    
    class IEDomAspDotNetLabel < IEDomSpanWrapper
      # this is just for reference. ASP.NET renders labels as SPAN tags.
    end
    
    class IEDomButtonWrapper < IEDomNodeWrapper
      def IEDomButtonWrapper.wrap_type_re
        /button|submit/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'click'
      end
    end
    
    class IEDomHNWrapper < IEDomNodeWrapper
      def IEDomHNWrapper.wrap_type_re
        /h[1-6]/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'innerText'
      end
    end
    
    class IEDomItalicWrapper < IEDomNodeWrapper
      def IEDomItalicWrapper.wrap_type_re
        /\Ai\z/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'innerText'
      end
    end
    
    class IEDomInputTextWrapper < IEDomNodeWrapper
      def IEDomInputTextWrapper.wrap_type_re
        /text/i
      end
      
      def initialize(node)
        @node = node
        @default_attribute = 'value'
      end
    end
  end
end

class String
  def chop_setter
    if (self[-1..-1] == '=')
      self.chop 
    else
      self
    end
  end
end

# backwards compatibility
include CLabs::IEC 
