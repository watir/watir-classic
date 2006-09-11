module Watir
  module PageContainer
    def enabled_popup(timeout=4)
      # Use handle of our parent window to see if we have any currently
      # enabled popup.
      hwnd_modal = 0
      Watir::until_with_timeout(timeout) do
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