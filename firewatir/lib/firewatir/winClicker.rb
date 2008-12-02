if /linux/i.match(RUBY_PLATFORM)
	require File.expand_path(File.join(File.dirname(__FILE__), 'x11'))

	# Linux/X11 implementation of WinClicker.
	# Not all functionality is present because of the differences between X11
	#   and Win32.
	class WinClicker

		def clickJavaScriptDialog(button="OK")
			click_window_button(/The page/,button)
		end

		def clickJSDialog_Thread(button="OK")
			puts "clickJSDialog_Thread Starting waiting..."
			sleep 3
			puts " clickJSDialog_Thread ... resuming"
			n = 0
			while n < 3
				sleep 1
				click_window_button(/The page/,button)
			end
		end

		def clearSecurityAlertBox
			click_window_button(/Unknown Authority/, "OK")
			click_window_button(/Domain Name Mismatch/, "Cancel")
		end

		def clickWindowsButton(title, button, maxWaitTime=30)
			start = Time.now
			w = window_by_title(title)
			until w || (Time.now - start > maxWaitTime)
				sleep(2) # Window search is pretty CPU intensive, so relax the requirement
				w = window_by_title(title)
			end
			unless w
				puts "clickWindowsButton: Cant make window active in specified time ( " + maxWaitTime.to_s + ") - no handle"
				return false
			end
			click_button(w,button)
		end

	private

		# Since it's impossible to read the button text in X11 windows,
		#   we have to specify keystrokes for the button names given the title.
		# TODO: A more elegant solution, or expand this list (to fill out popup text boxes for basic HTTP auth, perhaps).
		@@window_keys = [
			[/Unknown Authority/i, {'ok' => [:enter], 'cancel' => [:tab,:tab,:tab,:enter]}],
			[/Domain Name Mismatch/i, {'ok' => [:tab, :enter], 'cancel' => [:enter]}],
			[/Opening/i, {'ok' => [:sleep,:enter], 'cancel' => [:tab,:tab,:tab,:enter]}],
			[/The page at .* says/i, {'ok' => [:enter], 'cancel' => [:tab,:enter]}]
		]

		# Collection of all current firefox windows
		def firefox_windows(w = nil)
			collection = []
			windows = nil
			if w
				windows = [w]
			else
				windows = X11::Display.instance.screens.collect{|s| s.root_window}
			end
			windows.each do |window|
				if window.class == 'Gecko'
					collection << window
				end
				window.children.each do |c|
					collection << firefox_windows(c)
				end
			end
			return collection.flatten.compact
		end

		def window_by_title(title,windows=nil)
			pattern = nil
			if title.is_a?(Regexp)
				pattern = title
			else
				pattern = Regexp.compile(title,Regexp::IGNORECASE)
			end
			windows ||= X11::Display.instance.screens.collect{|s| s.root_window}
			if window = windows.find{|w| w.class == 'Gecko' && pattern.match(w.name)}
				return window
			else
				children = windows.reject{|w| w.class == 'Gecko'}.collect{|w| w.children}.flatten.compact
				if children.length > 0
					return window_by_title(pattern,children)
				end
			end
			return nil
		end

		def keystrokes(window,button) 
			keys = @@window_keys.find{|wk| wk.first.match(window.name)}
			if keys
				return keys.last[button.downcase]
			else
				return false
			end
		end

		def click_button(window, button)
			keys = nil
			if button.is_a?(Symbol)
				keys = [button]
			else
				keys = keystrokes(window,button)
			end
			return unless keys
			keys.each do |key|
				if key == :sleep
					@sleep_next = 1
					next
				end
				window.send_key(key,@sleep_next)
				@sleep_next = nil
			end
		end

	end
end
