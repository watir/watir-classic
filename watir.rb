#  This is WATIR the web application testing framework for ruby
#  Home page is http://rubyforge.com/projects/wtr
#
#  Version "$Revision$"
#
#  Typical usage: 
#   # include the controller 
#   require 'watir' 
#   # create an instance of the controller 
#   ie = IE.new  
#   # go to the page you want to test 
#   ie.goto("http://myserver/mypage") 
#   # to enter text into a text field - assuming the field is name "username" 
#   ie.textField(:name, "username").set("Paul") 
#   # if there was a text field that had an id of "company_ID", you could set it to Ruby Co: 
#   ie.textField(:id ,"company_ID").set("Ruby Co") 
#   # to click a button that has a caption of 'Cancel' 
#   ie.button(:caption, "Cancel").click 
#   
#  The ways that are available to identify an html object depend upon the object type. 
#   :id         used for an object that has an ID attribute  
#   :name      used for an object that has a name attribute 
#   :caption   used for finding buttons ( this is the value attribute of the button - <input type = button value="Stop"> )
#   :index      finds the object of a certain type at the index - eg button(:index , 2) finds the second button. This is 1 based. <br>
   
require 'win32ole'
require 'logger'
require 'watir/winClicker'

# this class is the simple WATIR logger. Any other logger can be used, however it must provide these methods.
class WatirLogger < Logger


   def initialize(  filName , logsToKeep, maxLogSize )

      super( filName , logsToKeep, maxLogSize )
      #@log = Logger.new( fileName ,5, 1024 * 1024)
      self.level = Logger::DEBUG
      self.datetime_format = "%d-%b-%Y %H:%M:%S"
      self.debug("Watir starting")
   end

      
   alias log info
      
end


# This class is used to display the spinner object that appears in the console when a page is being loaded
class Spinner

   def initialize
      @s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
      @i=0
   end

   # reverse the direction of spinning
   def reverse
      @s.reverse
   end
   # get the nextr character to display
   def next
      @i=@i+1
      @i=0 if @i>@s.length-1
      return @s[@i]
   end
end

# Root class for all Watir Exceptions
class WatirException < RuntimeError  
   def initialize(message="")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access an object that doesn't exist
class UnknownObjectException < WatirException
   def initialize(message="")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access a property that either does not exist or has not been found
class UnknownPropertyException < WatirException
   def initialize(message = "")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access an object that is in a disabled state
class ObjectDisabledException   < WatirException
   def initialize(message="")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access a frame that cannot be found 
class UnknownFrameException< WatirException
   def initialize(message = "")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access a form that cannot be found 
class UnknownFormException< WatirException
   def initialize(message="")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access an object that is in a read only state
class ObjectReadOnlyException  < WatirException
   def initialize(message = "")
      super(message)
   end
end

# This exception is thrown if an attempt is made to access an object when the specified value cannot be found
class NoValueFoundException < WatirException
   def initialize(message = "")
      super(message)
   end
end

# This exception gets raised if part of finding an object is missing
class MissingWayOfFindingObjectException < WatirException
   def initialize(message="")
      super(message)
   end
end
# This exception is raised if an attempt is made to access a table that doesn't exist
class UnknownTableException < WatirException
   def initialize(message="")
      super(message)
   end
end

# This exception is thrown if the window cannot be found
class NoMatchingWindowFoundException < WatirException
   def initialize(message="")
      super(message)
   end
end


class String
   def matches (x)
      return self == x
   end
end

class Regexp
   def matches (x)
      return self.match( x )
   end
end

class Dir
  def Dir.visit(dir = '.', files_first = false, &block)
    if files_first
      paths = []
      Find.find(dir) { |path| paths << path }
      paths.reverse_each {|path| yield path}
    else
      Find.find(dir, &block)
    end
  end
	# simulates unix rm -rf command
  def Dir.rm_rf(dir)
    Dir.visit(dir, true) do |path|
      if FileTest.directory?(path)
  begin
    Dir.unlink(path)
  rescue # Security Exception for Content.IE
  end
      else
  begin
    File.unlink(path)
  rescue #Security exception index.dat etc.
  end
      end
    end
  end
end

class WatirHelper
  #taken from shlObj.h  used in win32 SHGetSpecialFolderLocation
  #define CSIDL_INTERNET_CACHE            0x0020
  #define CSIDL_COOKIES                   0x0021
  #define CSIDL_HISTORY                   0x0022
  COOKIES = 0x0021
  INTERNET_CACHE = 0x0020

  def  WatirHelper.getSpecialFolderLocation(specFolderName)
      shell = WIN32OLE.new("Shell.Application")
      folder = shell.Namespace(specFolderName)
      folderItem = folder.Self
      folderPath = folderItem.Path
    end
  def  WatirHelper.deleteSpecialFolderContents(specFolderName)
    Dir.rm_rf(self.getSpecialFolderLocation(specFolderName))
  end

end

# This class is the base class for most actions ( such as "click ", etc. ) that occur on an object.
# This is not a class that users would normally access. 
class ObjectActions

   # Creates an instance of this class.
   # The "initialize" method creates several default properties for the object.
   # These properties are accessed using the setProperty and getProperty methods
   #   o  - the object that watir is using
   def initialize( o )
      @o = o
      @defaultProperties = { 
         "type"     =>  "type" ,
         "id"       =>  "id" ,
         "name"     => "name",
         "value"    => "value"  ,
         "disabled" => "disabled"
      }
      @ieProperties = Hash.new
      setProperties(@defaultProperties)
      @originalColor = nil
   end

   # This method sets the properties for the object
   def setProperties(propertyHash )
      if @o 
         propertyHash.each_pair do |a,b|
            begin
               setProperty(a , @o.invoke("#{b}" ) )
            rescue
               # Object probably doesn't support this item, so rescue
            end 
         end
      end  #if @o
   end

   # This method is used to set a property
   #   * name  - string - the name of the property to set
   #   * val   - string - the value to set
   def setProperty(name , val)
      @ieProperties[name] = val
   end

   # This method retrieves the value of the specified property.
   #   * name  - string - the name of the property to retrieve
   def getProperty(name)
      raise UnknownPropertyException("Unable to locate property, #{name}") if !@ieProperties.has_key?(name)
      return @ieProperties[name]
   end

   def getOLEObject()
      @ieController.clearFrame()
      return @o
   end

   # This method displays basic details about the object. Sample output for a button is shown.
   # Raises UnknownObjectException if the object is not found.
   #      name      b4
   #      type      button
   #      id         b5
   #      value      Disabled Button
   #      disabled   true
   def to_s
      @ieController.clearFrame()
      raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
      n = []
      @ieProperties.each_pair do |k,v|      
         n << "#{k}".ljust(18) + "#{v}"
      end
      return n
   end

   # This method is responsible for setting and clearing the colored highlighting on the currently active element.
   # use :set   to set the highlight
   #   :clear  to clear the highlight
   def highLight( setOrClear )
      if setOrClear == :set
         begin
            @originalColor = @o.style.backgroundColor
            @o.style.backgroundColor = @ieController.activeObjectHighLightColor
         rescue
            @originalColor = nil
         end
      else
         begin 
            @o.style.backgroundColor  = @originalColor unless @originalColor == nil
            @originalColor = nil
         rescue
            # we could be here for a number of reasons...
         ensure
            @originalColor = nil
         end
      end
   end

   #   This method clicks the active element.
   #   raises: UnknownObjectException  if the object is not found
   #   ObjectDisabledException if the object is currently disabled
   def click()
      @ieController.clearFrame()
      raise UnknownObjectException ,"Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
      raise ObjectDisabledException ,"object #{@how.to_s} and #{@what.to_s} is disabled" if !self.enabled?

      highLight(:set)
      @o.click()
      @ieController.waitForIE()
      highLight(:clear)
   end

   def flash
      @ieController.clearFrame()
      raise UnknownObjectException , "Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
      10.times do
         highLight(:set)
         sleep 0.05
         highLight(:clear)
         sleep 0.05
      end
   end
    
    # This method executes a user defined "fireEvent" for objects with JavaScript events tied to them such as DHTML menus.
    #   usage: allows a generic way to fire javascript events on page objects such as "onMouseOver", "onClick", etc.
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
   def fireEvent(event)
      @ieController.clearFrame()
      raise UnknownObjectException ,"Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
      raise ObjectDisabledException ,"object #{@how.to_s} and #{@what.to_s} is disabled"   if !self.enabled?
       
      highLight(:set)
      @o.fireEvent("#{event}")
      @ieController.waitForIE()
      highLight(:clear)
   end
     
    # This method sets focus on the active element.
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
   def focus()
      @ieController.clearFrame()
      raise UnknownObjectException("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
      raise ObjectDisabledException("Object #{@how.to_s} #{@what.to_s} is disabled ")   if !self.enabled?
      @o.focus()
   end

   # This methods checks to see if the current element actually exists. 
   def exists?
      @ieController.clearFrame()
      return false if @o == nil
      return true
   end

   # This method returns true if the current element is enable, false if it isn't.
   #   raises: UnknownObjectException  if the object is not found
   def enabled?
      @ieController.clearFrame()
      raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
      return false if @o.invoke("disabled")
      return true
   end
end


class FrameHandler

    def initialize()
        @frame = []
        @presetFrame = []
    end

    def clear
        @frame.clear
    end

    def clearPresetFrame
        @presetFrame.clear
    end

    def clearAll
        @frame.clear
        @presetFrame.clear
    end

    def addFrame( f)
        @frame << f
    end

    def addPresetFrame( f)
        @presetFrame << f
    end

    def usingFrame?
        return true if @frame.length > 0
        return false
    end

    def usingPresetFrame?
        return true if @presetFrame.length > 0
        return false
    end

    def usingFrames
        return true if usingFrame? | usingPresetFrame?
        return false
    end

    def presetFrame
        if @presetFrame[0] == nil
            return ""
        end
        return @presetFrame[0]
    end

    def getDocument( ie , doc = nil , frameNameIndex=0 )

        if @frame.length == 0 
            # using a preset frame
            frameToUse = @presetFrame[0]
            tempArray = @presetFrame
            puts "Using preset frame name is #{frameToUse }"
        elsif @frame.length == 1
            frameToUse = @frame[0]
            tempArray = @frame
        else
            # we are using multiple nested frames
            frameToUse = @frame[frameNameIndex ] 
            tempArray = @frame
        end

        if doc != nil
            allFrames = doc.frames
        else
            doc = ie.getIE.document
            allFrames = doc.frames
        end
        frameExists = false

        for i in 0 .. allFrames.length-1
            begin
                if frameToUse  == allFrames[i.to_s].name.to_s
                    frameExists = true   
                end
            rescue
                # probably no name on this object
            end
        end

        if frameExists == false
            clearAll
            raise UnknownFrameException , "Unable to locate a frame with name #{ frameToUse } " 
        end
        doc = doc.frames[frameToUse.to_s].document
        if tempArray.length > 0 and frameNameIndex < tempArray.length-1 
             doc=getDocument(ie ,doc , frameNameIndex+1   )
        end
        return doc

    end


end



# ARGV needs to be deleted to enable the Test::Unit functionatily that grabs
# the remaining ARGV as a filter on what tests to run.
$HIDE_IE = ARGV.include?('-b'); ARGV.delete('-b')

# This class is the main Internet Explorer Controller
# An instance of this must be created to access Internet Explorer.
class IE

   # Used internally to determine when IE has finished loading a page
   READYSTATE_COMPLETE = 4         

   # The default delay when entering text on a web page.
   DEFAULT_TYPING_SPEED = 0.08

   # The default time we wait after a page has loaded.
   DEFAULT_SLEEP_TIME = 0.1

   # The default color for highlighting objects as they are accessed.
   DEFAULT_HIGHLIGHT_COLOR = "yellow"

   # This is used to change the typing speed when entering text on a page.
   attr_accessor :typingspeed

   # This is used to change how long after a page has finished loading that we wait for.
   attr_accessor :defaultSleepTime

   # The color we want to use for the active object. This can be any valid web-friendly color.
   attr_accessor :activeObjectHighLightColor

   # When a new window is created it is stored in newWindow
   attr_accessor :newWindow

   attr_accessor :eventThread

   # this is used when forms are used. It shouldnt be used otherwise
   attr_accessor :frameHandler

   def createBrowser
   return WIN32OLE.new('InternetExplorer.Application')
   end


   def initialize( logger=nil, how = nil ,what = nil )
      @logger = logger
      if ((how != nil) and (what != nil))
         @ie = SeekWindow(how,what)
         #if it can not find window
         raise NoMatchingWindowFoundException ,"Unable to locate a window with #{ how} of #{what}"   if @ie == nil
      else
         @ie =  createBrowser
      end
      @ie.visible = ! $HIDE_IE
      @frameHandler = FrameHandler.new
      @form = nil
      @typingspeed = DEFAULT_TYPING_SPEED
      @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
      @defaultSleepTime = DEFAULT_SLEEP_TIME
   end

   def SeekWindow(how,what)

      puts "Seeking Window with #{how}: #{ what }"
      shell = WIN32OLE.new("Shell.Application")
      appWindows = shell.Windows()
      
      ieTemp = nil
      appWindows.each{|aWin| 
         print "Found a window: #{aWin}. "

         case how
            when :url
               print " url is: #{aWin.locationURL}\n"
               ieTemp = aWin if (what.matches(aWin.locationURL) )
            when :title
               # need rescue since normal windows explorer shells do not have document model.
               begin
                  print " url is: #{aWin.locationURL}\n"
                  ieTemp = aWin if (what.matches( aWin.document.title ) )
               rescue
               end
         end
      }
      return ieTemp
   end

   # this method returns the title of the window
   def title
      @ie.locationName
   end

    # this method returns the status of the window
    def getStatus
       status = @ie.statusText()
       raise NoStatusBarException if !@ie.statusBar
       return status
    end

   # this method goes to the previous page - the same as clicking the browsers back button
   # an WIN32OLERuntimeError exception is raised if the browser cant go back
   def back
      @ie.GoBack()
      waitForIE
   end
   # this method goes to the next page - the same as clicking the browsers forward button
   # an WIN32OLERuntimeError exception is raised if the browser cant go forward
   def forward
      @ie.GoForward()
      waitForIE
   end

   # this method refreshes the current page - the same as clicking the browsers refresh button
   # an WIN32OLERuntimeError exception is raised if the browser cant refresh
   def refresh
      @ie.refresh2(3)
      waitForIE
   end

   def captureEvents
      ev = WIN32OLE_EVENT.new(@ie, 'DWebBrowserEvents2')

      ev.on_event_with_outargs("NewWindow3") {|ppdisp, cancel, flags, formURL, toURL , args| 

         # http://msdn.microsoft.com/workshop/browser/webbrowser/reference/ifaces/dwebbrowserevents2/newwindow2.asp
         # http://groups.google.ca/groups?q=on_event_with_outargs&hl=en&lr=&group=comp.lang.ruby&safe=off&selm=e249d8e7.0410060843.3f55fa05%40posting.google.com&rnum=1
         # http://groups.google.ca/groups?q=on_event&hl=en&lr=&group=comp.lang.ruby&safe=off&selm=200202211155.UAA05077%40ums509.nifty.ne.jp&rnum=8

         puts "New Window!"
         puts "New URL: #{toURL }"
         puts "Flags: #{flags}"
         args[1] = true
         @newWindow = IE.new
         @newWindow.goto(toURL)
      }
      #@eventThread = Thread.new{
      #   while(1)
      #      sleep 0.01
      #      puts "checking event.."
      #      WIN32OLE_EVENT.message_loop
      #   end
      # }
   end

   def isEventThreadRunning?
      return false if @eventThread==nil
      return @eventThread.status
   end

   

   def dir
      return File.expand_path(File.dirname(__FILE__))
   end

   def log ( what )

      @logger.debug( what ) if @logger
      puts what
   end

   # This method returns the Internet Explorer object. 
   # Methods, properties,  etc. that the IEController does not support can be accessed.
   def getIE()
      return @ie
   end

    # This method sets the html frame to use for a single object to access.
    #   *   frameName  - string with the name of the frame to use
    def frame( frameName)

        @frameHandler.addFrame( frameName)
        return self
    end

    # This method is used internally to clear the name of the html frame to use.
    def clearFrame()
        @frameHandler.clear
    end

    # This method is used to set the html frame to use for multiple object actions.
    #   *   frameName  - string with the name of the frame to use
    def presetFrame( frameName )
        @frameHandler.addPresetFrame( frameName)
    end

    # This method is used to clear the html frame that is used on multiple object accesses.
    def clearPresetFrame( )
        @frameHandler.clearPresetFrame
    end

    # This method returns the name of the currently used frame. Only applies when the presetFrame method is used.
    def getCurrentFrame()
        return @frameHandler.presetFrame 
    end

   def form( how , formName=nil )
      # If only one value is supplied, it is a form name
      if formName == nil
            formName = how
            formHow = :name
      else
            formName = formName
            formHow = how
      end
      log "form how is #{formHow} name is #{formName}"      
      return Form.new(self, formHow, formName)      
   end


 # This method is used internally to set the document for Watir to use.
    #  Raises UnknownFrameException if a specified frame cannot be found.
    def getDocument(frameNameIndex= 0  , doc = nil)

        if @frameHandler.usingFrames
            doc = @frameHandler.getDocument( self )
        else
            doc = @ie.document
        end
        @doc = doc
        return doc
    end


   # This method returns true or false if the specified text was found.
   #  * text - string or regular expression - the string to look for
   def pageContainsText(text)
      #log "-------------"
      #log getDocument().body.innerText
      #log "-------------"
      returnValue = false
      retryCount = 0
      begin
         retryCount += 1
         if text.kind_of? Regexp

            if ( getDocument().body.innerText.match(text)  ) != nil
               log  "pageContainsText: Looking for: #{text} (regexp) - found it ok" 
               returnValue= true
            else
               log "pageContainsText: Looking for: #{text} (regexp)  - Didnt Find it" 
               returnValue= false
            end

         elsif text.kind_of? String

            if ( getDocument().body.innerText.index(text)  ) != nil
               log "pageContainsText: Looking for: #{text} (string) - found it ok" 
               returnValue= true
            else
               log  "pageContainsText: Looking for: #{text} (string)  - Didnt Find it" 
               returnValue= false
            end

         end 
      rescue
         retry if retryCount < 2 
      end
      clearFrame()
      return returnValue
   end

   # This method is used internally to cause an execution to stop until the page has loaded in Internet Explorer.
   def waitForIE( noSleep  = false )
         
      pageLoadStart = Time.now
      @pageHasReloaded= false

      #puts "waitForIE: busy" + @ie.busy.to_s
      s= Spinner.new
      while @ie.busy
         @pageHasReloaded = true
         sleep 0.02
         print  s.next
      end
      s.reverse

      #puts "waitForIE: readystate=" + @ie.readyState.to_s 
      until @ie.readyState == READYSTATE_COMPLETE
         @pageHasReloaded = true
         sleep 0.02
         print s.next
      end
      sleep 0.02


      if @ie.document.frames.length > 0 
         begin
            0.upto @ie.document.frames.length-1 do |i|
               until @ie.document.frames[i.to_s].document.readyState == "complete"
                  sleep 0.02
                  print s.next
               end
            end
         rescue

         end
      else
         until @ie.document.readyState == "complete"
            sleep 0.02
            print s.next
         end
      end
      print "\b"
      #puts "waitForIE Complete"
      s=nil
      sleep 0.01
      sleep @defaultSleepTime unless noSleep  == true
   end

   def wait
      waitForIE
   end

   # This method causes the Internet Explorer browser to navigate to the specified URL.
   #  * url  - string - the URL to navigate to
   def goto( url )
      @ie.navigate(url)
      waitForIE()
      sleep 0.2
      clearFrame()
   end

   # this method closes the Internet Explorer
   def close
      @ie.quit
   end

   # this method returns the HTML of the current page
   def getHTML()
      n=getDocument().body.innerHTML
      clearFrame()
      return n
   end

   # this method returns the text of the current document
   def getText()
      n= getDocument().body.innerText
      clearFrame()
      return n
   end


   # This method is used to display the available html frames that Internet Explorer currently has loaded.
   # This method is usually only used for debugging test scripts.
   def showFrames()
      if @ie.document.frames
         allFrames = @ie.document.frames
         puts "there are #{allFrames.length} frames"
         0.upto( allFrames.length-1 ) do |i| 
            begin
               fname = allFrames[i.to_s].name.to_s
               log "frame  index: #{i} name: #{fname}"
            rescue

            end
         end
      else
         log "no frames"
      end
      clearFrame()
   end

   # Show all forms displays all the forms that are on a web page.
   def showForms()
      if @ie.document.forms
         allForms = @ie.document.forms
         log "There are #{allForms.length} forms"
         for i in 0..allForms.length-1
            begin
               log "Form name: #{allForms[i.to_s].invoke("name").to_s}"
               log "      id: #{allForms[i.to_s].invoke("id").to_s}"
               log "   method: #{allForms[i.to_s].invoke("method").to_s}"
               log "   action: #{allForms[i.to_s].invoke("action").to_s}"

            rescue
               log "Form caused an exception!"
            end
         end
      else
         log " No forms"
      end
      clearFrame()
   end


   def showImages()
      doc = getDocument()
      doc.images.each do |l|
         log "image: name: #{l.name}"
         log "         id: #{l.invoke("id")}"
         log "      src: #{l.src}"
      end
      clearFrame()
   end


   def showLinks()
      doc = getDocument()
      doc.links.each do |l|
         log "Link: name: #{l.name}"
         log "      id: #{l.invoke("id")}"
         log "      href: #{l.href}"
         log "      text: #{l.innerText}"
      end
      clearFrame()
   end

  
   # this method shows the name, id etc of the object that is currently active - ie the element that has focus
   # its mostly used in irb when creating a script
   def showActive
       s = "" 
     
       current = getDocument.activeElement
        begin
            s=s+current.invoke("type").to_s.ljust(16)
        rescue
        end
        props=["name" ,"id" , "value" , "alt" , "src","innerText","href"]
        props.each do |prop|
            begin
                p = current.invoke(prop)
                s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
            rescue
                 #this object probably doesnt have this property
            end
        end
        s=s+"\n"
    end


   # This method shows the available objects on the current page.
   # This is usually only used for debugging or writing new test scripts.
   # This is a nice feature to help find out what HTML objects are on a page
   # when developing a test case using Watir.
   def showAllObjects()
      log "-----------Objects in  page -------------" 
      doc = getDocument()
      s = ""
      props=["name" ,"id" , "value" , "alt" , "src"]
      doc.all.each do |n|
         begin
            s=s+n.invoke("type").to_s.ljust(16)
         rescue
            next
         end
         props.each do |prop|
            begin
               p = n.invoke(prop)
               s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
            rescue
               # this object probably doesnt have this property
            end
         end
         s=s+"\n"
      end
      log s+"\n\n\n"
      clearFrame()
   end



   #This method retrieves an image on a web page for use.
   #Uses an <img src="image.gif"> HTML tag.
   def getImage( how, what )
      doc = getDocument()
      
      log "Finding an image how: #{how} What #{what}"
      
      images = doc.images
      o=nil
      images.each do |img|
            
         log "Image on page: src = #{img.src}"
            
         next unless o == nil
            
         case how
         when :src
            attribute = img.src
         when :name
            attribute = img.name
         when :id
            attribute = img.invoke("id")
         when :alt
            attribute = img.invoke("alt")
         else
            next
         end

         o = img if what.matches(attribute)
                        
      end # do
      clearFrame()
      return o
   end


   def getContainer()
      return getDocument.body.all
   end


   # This method is used to get a table from the page. 
   # :index (1 based counting)and :id are supported. 
   #  NOTE :name is not supported, as the table tag does not have a name attribute. It is not part of the DOM.
   # :index can be used when there are multiple forms on a page. 
   # The first form can be accessed with :index 1, the second :index 2, etc. 
   #   * how - symbol - the way we look for the table. Supported values are
   #                  - :id
   #                  - :index
   #   * what  - string the thing we are looking for, ex. id or index of the object we are looking for
   def getTable( how, what )
      allTables = getDocument.body.getElementsByTagName("TABLE")
      #log "There are #{ allTables.length } tables"
      table = nil
      tableIndex = 1
      allTables.each do |t|
         next  unless table == nil
         case how
            when :id
               if t.invoke("id").to_s == what.to_s
                  table = t
               end

            when :index
               if tableIndex == what.to_i
                  table = t
               end
         end
      end
      #puts "table - #{what}, #{how} Not found " if table ==  nil
      clearFrame()
      return table
   end
  
   # This is the main method for finding objects on a web page.
   #   * how - symbol - the way we look for the object. Supported values are
   #                  - :name
   #                  - :id
   #                  - :index
   #                  - :value
   #   * what  - string that we are looking for, ex. the name, or id tag attribute or index of the object we are looking for.
   #   * types - what object types we will look at. Only used when index is specified as the how.
   #   * value - used for objects that have one name, but many values. ex. radio lists and checkboxes
   def getObject( how, what , types=nil ,  value=nil )
      container = getContainer()

      if types
         if types.kind_of?(Array)
            elementTypes = types
         else
            elementTypes = [types]
         end
      end

      o = nil

      #log "getting object - how is #{how} what is #{what} types = #{types} value = #{value}"

      if how == :index
         o = getObjectAtIndex( container, what , types , value)
      elsif how == :caption || how == :value # only applies to button
         o = getObjectWithValue( what, container , "submit" , "button" )
      elsif how == :src || how ==:alt
         o = getObjectWithSrcOrAlt(what , how , container, types)
      else
         #log "How is #{how}"
         container.each do |object|
            next  unless o == nil
               
            begin
                  
               case how
                  when :id
                     attribute = object.invoke("id")
                  when :name
                     attribute = object.invoke("name")
               else
                  next
               end
                  
               if attribute == what
                  if types
                     if elementTypes.include?(object.invoke("type"))
                        if value
                           #log "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                           if object.value.to_s == value.to_s
                              o = object
                           end
                        else # no value
                           o = object
                        end
                     end
                  else # no types
                     o = object
                  end
               end
            rescue => e
               #log e.to_s + "\n" + e.backtrace.join("\n")
            end
               
         end
      end

      # If a value has been supplied, such as with a check box or a radio button, 
      # we need to go through the collection and get the correct one.
      if value
         begin 
            n.each do |thisObject|
               if thisObject.value == value.to_s and o ==nil
                  o = thisObject
               end 
            end
         rescue
            # probably no value on this object
         end
      end

      #reset the frame reference
      clearFrame()
      return o
   end

   # This method is used internally to locate an object that has a value specified.
   # It is normally used for buttons with a caption (HTML value attribute).
   #   * what            - what we are looking for - normally the value or caption of a button
   #   * container         - the container that we are searching in ( a form or the body of a document )
   #   * *htmlObjectTypes  - an array of the objects we are interested in
   def getObjectWithValue(what , container , *htmlObjectTypes )

      o = nil
      container.each do |r|
         next unless o == nil
         begin
            next unless htmlObjectTypes.include?(r.invoke("type").downcase)
            o = r if what.matches(r.value)
         rescue
            # may not have a value...
         end 
      end
      return o

   end

   # This method is used on buttons that are of type "image". Usually an <img src=""> or <input type="image"> HTML tag.
   # When an image is used to submit a form, it is treated as a button.
   #   * what            - what we are looking for - normally the src or alt tag attribute of a button
   #   * container         - the container that we are searching in ( a form or the body of a document )
   #   * htmlObjectTypes  - an array of the objects we are interested in
   def getObjectWithSrcOrAlt( what , how , container , htmlObjectTypes )
      o = nil
      
      container.each do |r|
      next unless o == nil
         begin
            next unless htmlObjectTypes.include?(r.invoke("type").downcase)
         
            case how
               when :alt
                  attribute = r.alt
               when :src
                  attribute = r.src
            else
               next
            end
 
            o = r if what.matches( attribute )         
         
         rescue
         end 
      end
      return o
   end



   # This method is used to locate an object when an "index" is used. 
   # It is used internally.
   #   * container  - the container we are looking in
   #   * index      - the index of the element we want to get - 1 based counting
   #   * types      - an array of the type of objects to look at
   #   * value      - the value of the object to get, used when getting itens like checkboxes and radios
   def getObjectAtIndex(container , index , types , value=nil)

      #log" getting object #{types.to_s}  at index( #{index}"

      o = nil
      objectIndex = 1
      container.each do | thisObject |
         begin

            if types.include?( thisObject.invoke("type") )
               begin 
                  oName = thisObject.invoke("name")
               rescue
                  oName = "unknown"
               end
               #log "checking object type is #{ thisObject.invoke("type") } name is #{oName} current index is #{objectIndex}  "

               if objectIndex.to_s == index.to_s
                  o = thisObject
                  if value
                     if value == thisObject.value
                        break
                     end
                  else
                     break
                  end

               end
               objectIndex +=1
            end
         rescue
         # probably doesnt support type
         end
      end
      return o
   end

   # This method gets a link from the document. This is a hyperlink, generally declared in the <a href="http://testsite">test site</a> HTML tag.
   #   * how  - symbol - how we get the link Supported types are:
   #                     :index - the link at position x , 1 based
   #                     :url   - get the link that has a url that matches. A regular expression match is performed
   #                     :text  - get link based on the supplied text. uses either a string or regular expression match
   #   * what - depends on how - an integer for index, a string or regexp for url and text
   def getLink( how, what )
      doc = getDocument()
      links = doc.links
      
   # Guard ensures watir won't crash if somehow the list of links is nil
   if (links == nil)
      raise UnknownObjectException, "Unknown Object in getLink: attempted to click a link when no links present"
   end

   link = nil
   case how
            
   when :index
      begin
         link = links[ (what-1).to_s ]
      rescue
         link=nil
      end
      
      when :url
         links.each do |thisLink|
            if thisLink.href.match(Regexp.escape(what)) 
               link = thisLink if link == nil
            end
         end
            
      when :text
         links.each do |thisLink|
            if what.matches(thisLink.innerText) 
               link = thisLink if link == nil
            end
         end
 
      when :id
         links.each do |thisLink|
            if what.matches(thisLink.invoke("id"))
               link = thisLink if link == nil
            end
         end
      when :name
         links.each do |thisLink|
            if what.matches(thisLink.invoke("name"))
               link = thisLink if link == nil
            end
         end



      else
         raise MissingWayOfFindingObjectException, "unknown way of finding a link ( {what} )"
      end
      #reset the frame reference
      clearFrame()
      
      # if no link found, link will be a nil.  This is OK.  Actions taken on links (e.g. "click") should rescue 
      # the nil-related exceptions and provide useful information to the user.
      clearFrame()
      return link
   end

   # this is the main method for acessing a table
   def table( how, what )
      t = Table.new( self , how, what)
      return t
   end

   # This is the main method for accessing a button. Often declared as an <input type = submit> tag.
   #  *  how   - symbol - how we access the button , :index, :caption, :name etc
   #  *  what  - string, int or re , what we are looking for, 
   # Returns a Button object.
   def button( how , what=nil  )
      if how.kind_of? Symbol
         raise MissingWayOfFindingObjectException   if what==nil
         b = Button.new(self, how , what )
      elsif how.kind_of? String
         log "how is a string - #{how}"
         b = Button.new(self, :caption, how)
      end
   end

   # This is the main method for accessing a text field. Usually an <input type = text> HTML tag.  
   #  *  how   - symbol - how we access the field , :index, :id, :name etc
   #  *  what  - string, int or re , what we are looking for, 
   # returns a TextFieldobject
   def textField( how , what )
      t = TextField.new(self , how, what)
   end

   # This is the main method for accessing a select box. Usually a <select> HTML tag.
   #  *  how   - symbol - how we access the select box , :index, :id, :name etc
   #  *  what  - string, int or re , what we are looking for, 
   # returns a SelectBox object
   def selectBox( how , what )
      s = SelectBox.new(self , how, what)
   end

   # This is the main method for accessing a check box. Usually an <input type = checkbox> HTML tag.
   #  *  how   - symbol - how we access the check box , :index, :id, :name etc
   #  *  what  - string, int or re , what we are looking for, 
   #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
   # returns a CheckBox object
   def checkBox( how , what , value=nil)
      c = CheckBox.new( self, how, what , value)
   end

   # This is the main method for accessing a radio button. Usually an <input type = radio> HTML tag.
   #  *  how   - symbol - how we access the radio button, :index, :id, :name etc
   #  *  what  - string, int or regexp , what we are looking for, 
   #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
   # returns a RadioButton object
   def radio( how , what , value=nil)
      r = RadioButton.new( self, how, what , value)
   end

   # This is the main method for accessing a link.
   #  *  how   - symbol - how we access the link, :index, :id, :name etc
   #  *  what  - string, int or re , what we are looking for, 
   # returns a Link object
   def link( how , what)
      l = Link.new(self , how, what )
   end

   # This is the main method for accessing images.
   #  *  how   - symbol - how we access the image, :index, :id, :name , :src
   #  *  what  - string, int or re , what we are looking for, 
   # returns an Image object
   def image( how , what)
      i = Image.new(self , how, what )
   end

   # This is the main method for accessing JavaScript popups.
   # returns a PopUp object
   def popup( )
      i = PopUp.new(self )
   end



   
end # class IE

# POPUP object
class PopUp
   def initialize( ieController )
      @ieController = ieController
   end

   def button( caption )
      return JSButton.new(  @ieController.getIE.hwnd , caption )
   end


end

class JSCommon

   def initialize()

   end
end



class JSButton < JSCommon
   def initialize( hWnd , caption )
      @hWnd = hWnd
      @caption = caption
   end

   def startClicker( waitTime = 3 )

      clicker = WinClicker.new
      clicker.clickJSDialog_Thread
      # clickerThread = Thread.new( @caption ) {
      #   sleep waitTime
      #   puts "After the wait time in startClicker"
      #   clickWindowsButton_hwnd(hwnd , buttonCaption )
      #}
   end

end


#   Form object 
#   * ieController  - an instance of an IEController
#   * how         - symbol - how we access the form (:name, :id, :index, :action, :method)
#   * what         - what we use to access the form
class Form < IE
   def initialize( ieController, how, what )
      @ieController = ieController
      @formHow = how
      @formName = what
      @frameHandler = @ieController.frameHandler

      log "Get form  formHow is #{@formHow}  formName is #{@formName} "
      count = 1
      doc = @ieController.getDocument()
      doc.forms.each do |thisForm|
      #0.upto(doc.forms.length -1 ) do |i|
         #thisForm = doc.forms[i.to_s]
         next unless @form == nil
         log "form on page, name is " + thisForm.invoke("name").to_s
         begin
            log "its a collection of forms - length is: " + thisForm.invoke("name").length.to_s
         rescue
            log "not a collection of forms"
         end

         case @formHow
            when :name 
               if thisForm.name == @formName
                  @form = thisForm
               end

            when :id
               if thisForm.invoke("id").to_s == @formName.to_s
                  @form = thisForm
               end

            when :index
               if count == @formName.to_i
                  @form = thisForm
               end

            when :method
               if thisForm.invoke("method").downcase == @formName.downcase
                  @form = thisForm
               end

            when :action
               if @formName.matches(thisForm.action)
                  @form = thisForm
               end

         end
         count = count +1
      end
      if @form == nil
         log "No form found!"
      else      
         log "set @form "   #to form with name #{@form.name}"
      end
      
      @typingspeed = ieController.typingspeed      
      @activeObjectHighLightColor = ieController.activeObjectHighLightColor      
   end

   # Find the specified form  
   def getForm()

   end
  
   def waitForIE(arg = false)
      @ieController.waitForIE(arg)
   end

   def getContainer()
      @ieController.clearFrame()
      raise UnknownFormException , "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
      @form.elements.all
   end   

   def exists?
      @ieController.clearFrame()
      @form ? true : false
   end

   # Submit the data -- equivalent to pressing Enter or Return to submit a form. 
   def submit()
      @ieController.clearFrame()
      raise UnknownFormException ,  "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
      @form.submit 
      @ieController.waitForIE
   end   

end # class Form


# This class is used for dealing with tables.
# This will not be normally used by users, as the table method of IEController would return an initialised instance of a table.
class Table < ObjectActions

   # Returns an initialized instance of a table object
   #   * ieController  - an instance of an IEController
   #   * how         - symbol - how we access the table
   #   * what         - what we use to access the table - id, name index etc 
   def initialize( ieController,  how , what )
      @ieController = ieController
      @o = ieController.getTable( how, what )
      super( @o )
      @how = how
      @what = what
   end


   # This method returns the number of rows in the table.
   # Raises an UnknownTableException if the table doesnt exist.
   def rows
      @ieController.clearFrame()
      raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} "  if @o == nil
      table_rows = @o.getElementsByTagName("TR")
      return table_rows.length
   end

   # This method returns the number of columns in the table.
   # Raises an UnknownTableException if the table doesn't exist.
   def columns( rowToUse = 1)
      @ieController.clearFrame()
      raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} "  if @o == nil
      table_rows = @o.getElementsByTagName("TR")
      cols = table_rows[rowToUse.to_s].getElementsByTagName("TD")
      return cols.length
   end

   # This method returns the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
   # Raises an UnknownTableException if the table doesn't exist.
   def to_a
      @ieController.clearFrame()
      raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
      y = []
      table_rows = @o.getElementsByTagName("TR")
      for row in table_rows
         x = []
         for td in row.getElementsbyTagName("TD")
            x << td.innerText.strip
         end
         y << x
      end
      return y

   end

end



# This class is the means of accessing an image on a page.
# It would not normally be used by users, as the image method of IEController would return an initialised instance of an image.
class Image < ObjectActions

   # Returns an initialized instance of a image  object
   #   * ieController  - an instance of an IEController
   #   * how         - symbol - how we access the image
   #   * what         - what we use to access the image, text, url, index etc
   def initialize( ieController,  how , what )
      @ieController = ieController
      @o = ieController.getImage( how, what )
      super( @o )
      @how = how
      @what = what
      property = {
         "src"             =>  "src" ,
         "fileCreatedDate" => "fileCreatedDate" ,
         "fileSize"        => "fileSize" ,
         "width"           => "width" ,
         "height"          => "height"
      }
      setProperties(property )
   end

   # This method attempts to find out if the image was actually loaded by the web browser. 
   # If the image was not loaded, the browser is unable to determine some of the properties. 
   # We look for these missing properties to see if the image is really there or not. 
   # If the Disk cache is full ( tools menu -> Internet options -> Temporary Internet Files) , it may produce incorrect responses.
   def hasLoaded?
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate image using #{@how} and #{@what} " if @o==nil
      return false  if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
      return true
   end

end


# This class is the means of accessing a link on a page
# It would not normally be used bt users, as the link method of IEController would returned an initialised instance of a link.
class Link < ObjectActions
   # Returns an initialized instance of a link object
   #   * ieController  - an instance of an IEController
   #   * how         - symbol - how we access the link
   #   * what         - what we use to access the link, text, url, index etc
   def initialize( ieController,  how , what )
      @ieController = ieController
      begin
         @o = ieController.getLink( how, what )
         rescue UnknownObjectException
            @o = nil
         end
      super( @o )
      @how = how
      @what = what
   end
end


# This class is the way in which select boxes are manipulated.
# it would not normally be created by a user, as it is returned by the selectBox method of IEController
class SelectBox < ObjectActions
   # returns an initialized instance of a SelectBox object
   #   * ieController  - an instance of an IEController
   #   * how         - symbol - how we access the select box
   #   * what         - what we use to access the select box, name, id etc
   def initialize( ieController,  how , what )
      @ieController = ieController
      @o = ieController.getObject( how, what , ["select-one","select-multiple"] )
      super( @o )
      @how = how
      @what = what
   end

   # This method clears the selected items in the select box
   def clearSelection
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} " if @o==nil
      highLight( :set)
      @o.each do |selectBoxItem|
            selectBoxItem.selected = false
            @ieController.waitForIE()
      end
      highLight( :clear)
   end

   # This method selects an item, or items in a select box.
   # Raises NoValueFoundException   if the specified value is not found.
   #  * item   - the thing to select, string, reg exp or an array of string and reg exps

   def select( item )
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} "  if @o==nil
      if item.kind_of?( Array ) == false
            items = [item]
      else
            items = item 
      end

      highLight( :set)
      doBreak = false
      items.each do |thisItem|

         @ieController.log "Setting box #{@o.name} to #{thisItem} #{thisItem.class} "

            @o.each do |selectBoxItem|
               @ieController.log " comparing #{thisItem } to #{selectBoxItem.text}"
               if thisItem.matches( selectBoxItem.text)
                  matchedAnItem = true
                  if selectBoxItem.selected == true
                     @ieController.log " #{selectBoxItem.text} is already selected"
                     doBreak = true
                  else
                     @ieController.log " #{selectBoxItem.text} is being selected"
                     selectBoxItem.selected = true
                     @o.fireEvent("onChange")
                     doBreak = true
                  end
                  @ieController.waitForIE()
                  break if doBreak
               end
            end

         raise NoValueFoundException , "Selectbox was found, but didnt find item #(item) "   if doBreak == false
      end
      highLight( :clear )
   end

   # This method returns all the items in the select list as an array. An empty array is returned if the select box has no contents.
   # Raises UnknownObjectException if the select box is not found
   def getAllContents()
      @ieController.clearFrame()
      raise UnknownObjectException  ,  "Unable to locate a selectbox  using #{@how} and #{@what} " if @o==nil
      returnArray = []

      @ieController.log "There are #{@o.length} items"

      @o.each do |thisItem|
         returnArray << thisItem.text
      end
      return returnArray 

   end

   # This method returns all the selected items from the select box as an array.
   # Raises UnknownObjectException if the select box is not found.
   def getSelectedItems
      raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} "  if @o==nil
      returnArray = []
      @ieController.log "There are #{@o.length} items"
      @o.each do |thisItem|
         if thisItem.selected == true
            @ieController.log "Item ( #{thisItem.text} ) is selected"
            returnArray << thisItem.text 
         end
      end
      return returnArray 
   end
end

# This is the main class for accessing buttons.
# Normally a user would not need to create this object as it is returned by the IEController Button method.
class Button < ObjectActions
   # Create an instance of the button object
   def initialize( ieController,  how , what )
      @ieController = ieController
      @o = ieController.getObject( how, what , ["button" , "submit" , "image"] )
      super( @o )
      @how = how
      @what = what
   end
end

# This class is the parent class for radio buttons and check boxes. It contains methods common to both.
# It should not be created by users.
class RadioCheckCommon < ObjectActions
   # Constant for setting, or determining if a check box or radio button is set.
   CHECKED = true
   # Constant for unsetting, or determining if a check box or radio button is unset.
   UNCHECKED = false

   def initialize( o )
      super(o)
   end

   # This method determines if a radio button or check box is set.
   # Returns true is set or false if not set.
   # Raises UnknownObjectException if its unable to locate an object.
   def isSet?
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate a radio button using #{@how} and #{@what} "if @o==nil
      return true if @o.checked
      return false
   end

   # This method clears a radio button or check box. Note, with radio buttons one of them will almost always be set.
   # Returns true if set or false if not set.
   #   Raises UnknownObjectException if its unable to locate an object
   #         ObjectDisabledException  IF THE OBJECT IS DISABLED 
   def clear
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
      raise ObjectDisabledException  ,  "object #{@how} and #{@what} is disabled " if !self.enabled?
      @o.checked = false
      @o.fireEvent("onClick")
      @ieController.waitForIE()
   end

   # This method sets the radio list item or check box.
   #   Raises UnknownObjectException  if its unable to locate an object
   #         ObjectDisabledException  IF THE OBJECT IS DISABLED 
   def set
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
      raise ObjectDisabledException  ,  "object #{@how} and #{@what} is disabled " if !self.enabled?
      highLight( :set)
      @o.checked = true
      @o.fireEvent("onClick")
      @ieController.waitForIE()
      highLight( :clear )
   end

   # This method gets the state of a radio list item or check box.
   # Returns CHECKED or UNCHECKED
   #   Raises UnknownObjectException  if its unable to locate an object
   def getState
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
      return CHECKED if @o.checked == true
      return UNCHECKED 
   end

end

# This class is the main class for radio buttons.
# It shouldn't normally be created, as the radio method of IEController will return an initialized object.
class RadioButton < RadioCheckCommon
   
   def initialize( ieController,  how , what , value=nil )
      @ieController = ieController
      @o = ieController.getObject( how, what , "radio" , value)
      super( @o )
      @how = how
      @what = what
      @value = value
   end
end

# This class is the main class for Check boxes.
# It shouldnt normally be created, as the checkBox method of IEController will return an initialized object.
class CheckBox < RadioCheckCommon

   def initialize( ieController,  how , what , value=nil )
      @ieController = ieController
      @o = ieController.getObject( how, what , "checkbox", value)
      super( @o )
      @how = how
      @what = what
      @value = value
   end

end

# This class is the main class for Text Fields
# It shouldn't normally be created, as the textField method of IEController will return an initialized object.
class TextField < ObjectActions
   
   def initialize( ieController,  how , what )
      @ieController = ieController
      @o = ieController.getObject( how, what , ["text" , "password","textarea"] )
      super( @o )
      @how = how
      @what = what
      @properties = {
         "maxLength"  =>      "maxLength" ,
         "length"     =>      "length" 
      }
   end

   # This method returns true or false if the text field is read only.
   #   Raises  UnknownObjectException if the object can't be found.
   def readOnly?
      @ieController.clearFrame()
      raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "   if @o==nil
      return @o.readOnly 
   end   

   # This method returns the current contents of the text field as a string.
   #   Raises  UnknownObjectException if the object can't be found
   def getContents()
      @ieController.clearFrame()
      raise UnknownObjectException if @o==nil
      return self.getProperty("value")
   end

   # This method returns true orfalse if the text field contents is either a string match 
   # or a regular expression match to the supplied value.
   #   Raises  UnknownObjectException if the object can't be found
   #   * containsThis - string or reg exp  -  the text to verify 
   def verify_contains( containsThis )
      raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil

      if containsThis.kind_of? String
         return true if self.getProperty("value") == containsThis
      elsif containsThis.kind_of? Regexp
         return true if self.getProperty("value").match(containsThis) != nil
      end
      @ieController.clearFrame()
      return false
   end
  
   # This method clears the contents of the text box.
   #   Raises  UnknownObjectException if the object can't be found
   #   Raises  ObjectDisabledException if the object is disabled
   #   Raises  ObjectReadOnlyException if the object is read only
   def clear()
      raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
      raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
      raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?

      highLight(:set)

      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      @o.fireEvent("onChange")
      @ieController.waitForIE()
      highLight(:clear)
      @ieController.clearFrame()

   end

   # This method appens the supplied text to the contents of the text box.
   #   Raises  UnknownObjectException if the object cant be found
   #   Raises  ObjectDisabledException if the object is disabled
   #   Raises  ObjectReadOnlyException if the object is read only
   #   * setThis  - string - the text to append
   def append( setThis)
      raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
      raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
      raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?


      highLight(:set)
      @o.scrollIntoView
      @o.focus
      doKeyPress( setThis )
      highLight(:clear)
      @ieController.clearFrame()

   end

   # This method sets the contents of the text box to the supplied text 
   #   Raises  UnknownObjectException if the object cant be found
   #   Raises  ObjectDisabledException if the object is disabled
   #   Raises  ObjectReadOnlyException if the object is read only
   #   * setThis  - string - the text to set 
   def set( setThis )
      raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
      raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
      raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?

      highLight(:set)
      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      doKeyPress( setThis )
      highLight(:clear)
      @ieController.clearFrame()

   end

   # This method is used internally by setText and appendText
   # It should not be used externally.
   #   * value   - string  - The string to enter into the text field
   def doKeyPress( value )
      begin
         maxLength = @o.maxLength
         if value.length > maxLength
            value = suppliedValue[0 .. maxLength ]
            log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
         end
      rescue
         # probably a text area - so it doesnt have a max Length
         maxLength = -1
      end

      for i in 0 .. value.length-1   
         sleep @ieController.typingspeed   # typing speed
         c = value[i]
         #log  " adding c.chr " + c.chr.to_s
         @o.value = @o.value.to_s + c.chr
         @o.fireEvent("onKeyPress")
         @ieController.waitForIE(true)
      end
   end
end

