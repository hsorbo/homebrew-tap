# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb
class PicoSdk < Formula
  desc "Pico SDK"
  homepage "https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf"
  url "https://github.com/raspberrypi/pico-sdk/archive/refs/tags/1.4.0.tar.gz"
  sha256 "951d1d316d9a01c734c5ec53e766a2d03fb44f405a2494bac9a8a7c178e25918"
  license "BSD-3-Clause"

  depends_on "cmake" => :build

  def install
    chdir "tools/pioasm" do
      system "cmake", "-S", ".", *std_cmake_args
      system "cmake", "--build", "."
      bin.install "pioasm"
    end
    
    chdir "tools/elf2uf2" do
      system "cmake", "-S", ".", *std_cmake_args
      system "cmake", "--build", "."
      bin.install "elf2uf2"
    end
    ["cmake", "docs", "external", "lib", "src", "test"].each do |n|
      (share/"pico-sdk").install "#{n}"
    end
    Dir.glob("*.*") do |n|
      (share/"pico-sdk").install "#{n}"
    end
  end
  test do
    system "pioasm --help"
  end

  def caveats
    "You may want to add PICO_SDK_PATH=#{share}/pico-sdk to your environment"
  end

end
