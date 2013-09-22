require "tmpdir"
require "base64"
require "win32/screenshot"

module Watir
  # Returned by {Browser#screenshot}.
  class Screenshot
    def initialize(browser_hwnd)
      @hwnd = browser_hwnd
    end

    # Save screenshot to the file.
    #
    # @param [String] path path to the image.
    def save(path)
      screenshot.write(path)
    end

    # @return [String] image in png format.
    def png
      path = File.expand_path "temporary-image-#{Time.now.to_i}.png", Dir.tmpdir
      save path
      File.open(path, "rb") {|file| file.read}
    ensure
      File.delete path rescue nil
    end

    # @return [String] {#png} image formatted as base64.
    def base64
      Base64.encode64 png
    end

    private

    def screenshot
      ::Win32::Screenshot::Take.of(:window, :hwnd => @hwnd)
    end
  end
end
