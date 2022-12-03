class Picotool < Formula
  desc "Tool for inspecting RP2040 binaries, and interacting with RP2040 devices"
  homepage "https://github.com/raspberrypi/picotool"
  url "https://github.com/raspberrypi/picotool/archive/refs/tags/1.1.0.tar.gz"
  sha256 "2ed06b469913c86dea3d1e84d01e27c93853a4ebd65cebbefd2ad2c6d3e97780"
  license "BSD-3-Clause"

depends_on "cmake" => :build
depends_on "pico-sdk"
depends_on "libusb"

  def install
    sdk_path = Formula["pico-sdk"].opt_prefix + "share/pico-sdk"
    system "cmake", "-S", ".", "-B", "build",  "-DPICO_SDK_PATH="+sdk_path, *std_cmake_args
    chdir "build" do
      system "make", "install"
    end
  end

  test do
    system "picotool -v"
  end
end
