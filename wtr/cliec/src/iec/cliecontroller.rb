# $Id$
=begin
--------------------------------------------------------------------------
Copyright (c) 2001-2002, Chris Morris All rights reserved.

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
      VERSION = CLabs::Version.new(2003, 362, 0)
    rescue LoadError                                                 
      VERSION = '2003.362.0'                                            
    end                                                              
    # END_VERSION

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

    class ClIEController
      attr_reader :ie

      READYSTATE_COMPLETE = 4

      def initialize(visible = false)
        @ie = WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = visible
      end

      def close
        @ie.quit
      end

      def form(index = 0)
        @ie.document.forms(index)
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

      def method_missing(methID, *args)
        # forward on to ie
        @ie.send(methID, *args)
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

      def wait
        waitForIE
      end

      def waitForIE
        # busy seems to return control too soon, but going
        # direct to another check of readyState is too fast,
        # browser can still be in READYSTATE_COMPLETE
        while @ie.busy
          sleep 0.1
        end

        until @ie.readyState == READYSTATE_COMPLETE
          sleep 0.1
        end
      end
    end

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

    class GUIFormWrapper
      def initialize(form)
        @form = form
      end

      def methodIsSetter(methodName)
        return methodName[-1, 1] == '='
      end

      def method_missing(methID, *args)
        methodName = methID.id2name
        setter = methodIsSetter(methodName)
        methodName.chop! if setter
        if methodIsFormField(methodName)
          sendToFormField(methodName, setter, *args)
        else
          @form.send(methID, *args)
        end
      end

      def methodIsFormField(methodName)
        raise "abstract method methodIsFormField in GUIFormWrapper"
      end

      def getFormField(fieldName)
        @form.send(fieldName.intern)
      end

      def sendToFormField(methodName, setter, *args)
        @field = getFormField(methodName)
        methodName = getDefaultAttributeForField
        methodName = methodName + '=' if setter
        @field.send(methodName, *args)
      end
    end

    class IEDomFormWrapper < GUIFormWrapper
      def getDefaultAttributeForField
        element = @field  # dom form fields are called elements
        # type is a Ruby Object method, so invoke must be called to make sure
        # it actually goes over to the WIN32OLE instance
        case element.invoke('type')
          when 'checkbox' then 'checked'
          when 'select-one' then @field = IEDomSelectWrapper.new(@field); 'value'
          else 'value'
        end
      end

      def sendToFormField(methodName, setter, *args)
        if methodIsDotNetLabel(methodName)
          raise 'cannot set ASP.NET label ' + methodName if setter
          @form.all(methodName).innerText
        else
          super(methodName, setter, *args)
        end
      end

      def methodIsFormElement(methodName)
        return @form.elements(methodName) != nil
      end

      def methodIsDotNetLabel(methodName)
        # terminology is confusing. All nodes are either nodeType 1 (element)
        # or nodeType 3 (text) [see http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/nodetype.asp]

        # but span elements are not included in form.elements, only
        # button, input, textArea and select elements are
        # see [http://msdn.microsoft.com/workshop/author/dhtml/reference/collections/elements.asp]

        element = @form.all(methodName)
        if !element.nil?
          # ASP.NET labels are rendered as SPAN tags in html
          return (element.outerHtml =~ /^<SPAN/)
        else
          return false
        end
      end

      def methodIsFormField(methodName)
        return methodIsFormElement(methodName) || methodIsDotNetLabel(methodName)
      end

      def active_element
        ClIEController.get_active_element_name(@form.ownerDocument.activeElement)
      end

      alias activeElement active_element
    end

    class IEDomSelectWrapper
      def initialize(selectElement)
        @select = selectElement
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

    # .Net System.Windows.Forms.Form registered as COM (regasm.exe)
    class WindowsFormWrapper < GUIFormWrapper
      def getDefaultAttributeForField
        # type is an Object method, so invoke must be called to make sure
        # it actually goes over to the WIN32OLE instance
        case @field.gettype.tostring
          when 'textbox' then 'text'
          else 'text'
        end
      end

      # keeping this method, because it's better. But, while it worked in VS.Net Beta 2
      # it's not working in RC1.
      def methodIsFormField_Old(methodName)
        controls = @form.controls
        result = false
        controls.count.times { | index |
          result = (controls.item(index).name == methodName)
          break if result
        }
        result
      end

      # current workaround method requiring some hooks in the form code itself
      def methodIsFormField(methodName)
        @form.IsFieldOrProperty(methodName)
      end

      # current workaround method
      # for VS.Net RC1
      def sendToFormField(methodName, setter, *args)
        if setter
          @form.SetValue(methodName, *args)
        else
          @form.GetValue(methodName)
        end
      end

      def submit(btnName)
        # @form.send(btnName.intern).PerformClick
        # workaround for RC1
        @form.DoButtonClick(btnName)
      end
    end
  end
end

include CLabs::IEC
