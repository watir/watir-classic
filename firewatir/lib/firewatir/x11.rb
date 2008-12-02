require 'dl/import'
require 'dl/struct'

require 'singleton'

module X11
	class << self
		include X11 # Do this so we can call imported libraries directly on X11
	end

	# Load the X11 library
	extend DL::Importable
	dlload "libX11.so" 
	
	# Import necessary functions from X11 here.
	import("XOpenDisplay", "unsigned long", ["char*"])
	import("XScreenCount", "int", ["unsigned long"])
	import("XRootWindow", "unsigned long", ["unsigned long","int"])

	import("XFree", "int", ["void*"])

	import("XFetchName", "int", ["unsigned long","unsigned long","char**"])
	import("XGetClassHint", "int", ["unsigned long","unsigned long","void*"])
	import("XQueryTree", "int", ["unsigned long","unsigned long","unsigned long*","unsigned long*","unsigned long**","unsigned int*"])

	import("XSetInputFocus", "int", ["unsigned long","unsigned long","int","long"])
	import("XSendEvent", "int", ["unsigned long","unsigned long","int","long","void*"])
	import("XFlush", "int", ["unsigned long"])

	# Structs we will use in API calls.
	# Pointer structs are necessary when the API uses a pointer parameter for a return value.
	ULPPointer = struct [
		"long* value"
	]
	ULPointer = struct [
		"long value"
	]
	CPPointer = struct [
		"char* value"
	]
	UIPointer = struct [
		"int value"
	]
	# Info about window class
	XClassHint = struct [
		"char* res_name",
		"char* res_class"
	]
	# Event struct for key presses
	XKeyEvent = struct [
		"int type",
		"long serial",
		"int send_event",
		"long display",
		"long window",
		"long root",
		"long subwindow",
		"long time",
		"int x",
		"int y",
		"int x_root",
		"int y_root",
		"int state",
		"int keycode",
		"int same_screen"
	]

	# End of library imports.

	# X11 Display. Singleton -- assumes single display.
	# Assumes the current display is the same as the one running FireFox.
	# Represented by memory pointer (which we treat in-code as an unsigned long).
	class Display
		include Singleton

		def initialize
			@xdisplay = X11.xOpenDisplay("");
		end

		# Array of screens associated with this display.
		def screens
			nScreens = X11.xScreenCount(@xdisplay);
			(0...nScreens).collect{|n| Screen.new(n,@xdisplay)}
		end
	end

	# A display screen, for multi-monitor displays like mine ;-)
	# Represented by display pointer and screen number.
	class Screen
		def initialize(screen_num,xdisplay)
			@screen_num = screen_num
			@xdisplay = xdisplay
		end

		# Root window containing all other windows in this screen.
		def root_window
			Window.new(X11.xRootWindow(@xdisplay,@screen_num),@screen_num,@xdisplay)
		end
	end

	# An X11 Window (toplevel window, widget, applet, etc.)
	# Represented by its XID, an unsigned long.
	class Window
		attr_reader :xid, :name, :class, :hint, :parent

		def initialize(xid,screen_num,xdisplay,parent=nil)
			@xid = xid
			@screen_num = screen_num
			@xdisplay = xdisplay
			@parent = parent
			load_standard
		end

		# Child windows
		def children
			tree[:children].collect{|c| Window.new(c,@screen_num,@xdisplay,self)}
		end

		# XID of parent window
		def parent_xid
			parent ? parent.xid : nil
		end

		# Send a key press to this window
		def send_key(key=:enter,sleep=nil)
			# TODO expand this list out, add support for shift, etc.
			@@keys = {:enter => 36, :tab => 23} unless defined?@@keys
			keycode = @@keys[key]
			X11.xSetInputFocus(@xdisplay, @xid, 1, 0)
			sleep(sleep) if sleep
			e = create_key_event
			e.keycode = keycode
			e.type = 2 # press
			X11.xSendEvent(@xdisplay,@xid,1,1,e)
			e.type = 3 # release
			X11.xSendEvent(@xdisplay,@xid,1,2,e)
			X11.xFlush(@xdisplay)
		end

		private

		# Retrieve this window's portion of the window tree
		# Includes display root, parent, and children
		def tree
			tree = {:children => [], :parent => 0, :root => 0}
			children = ULPPointer.malloc
			root = ULPointer.malloc
			parent = ULPointer.malloc
			n = UIPointer.malloc
			r=X11.xQueryTree(@xdisplay,@xid,root,parent,children,n)
			tree[:parent] = parent.value
			tree[:root] = root.value
			tree[:children] = children.value.to_s(4*n.value).unpack("L*") if children.value
			tree
		end

		# Load some standard attributes (name and class)
		def load_standard
			name = CPPointer.malloc
			if X11.xFetchName(@xdisplay,@xid,name) != 0
				@name = name.value.to_s
				X11.xFree name.value
			end
			classHint = XClassHint.malloc
			res = X11.xGetClassHint(@xdisplay,@xid,classHint)
			if res != 0 then
				@class = classHint.res_name.to_s
				@hint = classHint.res_class.to_s
				X11.xFree classHint.res_name
				X11.xFree classHint.res_class
			end
		end

		# Create an X11 Key Event for this window and set defaults
		def create_key_event
			ke = XKeyEvent.malloc
			ke.serial = 0
			ke.send_event = 1
			ke.display = @xdisplay
			ke.window = @xid
			ke.subwindow = 0
			ke.root = tree[:root]
			ke.time = Time.now.sec
			ke.state = 0
			ke.same_screen = 0
			return ke
		end

	end

end

