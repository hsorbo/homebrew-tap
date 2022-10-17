class Ezp2010 < Formula
  desc "Flashing roms using the ezp2010 programmer"
  homepage ""
  url "https://github.com/hsorbo/ezp2010/archive/refs/tags/v0.1.tar.gz"
  sha256 "06130778b259032c9a517f57a8f6e157cc2416630d7daa6d3d25f0b8b83c0aa1"
  license "GPL-2.0"
  
  depends_on "rust" => :build
  depends_on "pkg-config" => :build
  
  def install
    ENV["LIBUSB_STATIC"] = "1"
    system "cargo", "install", *std_cargo_args
  end

  test do
    system "#{bin}/ezp", "list"
  end
end
