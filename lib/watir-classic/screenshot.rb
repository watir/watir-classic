require "tmpdir"
require "base64"
require "win32/screenshot"

module Watir
  class Screenshot
    def initialize(browser_hwnd)
      @hwnd = browser_hwnd
    end

    def save(path)
      screenshot.write(path)
    end

    def png
      path = File.expand_path "temporary-image-#{Time.now.to_i}.png", Dir.tmpdir
      save path
      File.open(path, "rb") {|file| file.read}
    ensure
      File.delete path rescue nil
    end

    def base64
      Base64.encode64 png
    end

    private

    def screenshot
      ::Win32::Screenshot::Take.of(:window, :hwnd => @hwnd)
    end
  end
end
