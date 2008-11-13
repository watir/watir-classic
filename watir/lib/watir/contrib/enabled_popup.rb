# http://www.vbcity.com/forums/topic.asp?tid=108859
require 'watir/ie'
module Watir
  module PageContainer
    include Win32
    def enabled_popup(timeout=4)
      # Use handle of our parent window to see if we have any currently
      # enabled popup.
      hwnd_modal = 0
      Waiter.wait_until(timeout) do
        hwnd_modal, arr = GetWindow.call(hwnd, GW_ENABLEDPOPUP)
        hwnd_modal > 0
      end
      # use hwnd() method to find the IE or Container hwnd (overriden by IE)
      if hwnd_modal == hwnd() || 0 == hwnd_modal
        hwnd_modal = nil
      end
      hwnd_modal
    end
  end
end