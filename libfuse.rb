# Upstream libfuse 3 with a macOS mount backend (lib/mount_darwin.c), which
# mounts through fusermount3 from Fusetta (https://github.com/hsorbo/fusetta).
#
# patches/libfuse-3.18.3-darwin.patch is a copy of fusetta's
# patches/libfuse-3.18.3-darwin.patch; update it from there.
class Libfuse < Formula
  desc "Reference implementation of the FUSE interface, with an FSKit backend for macOS"
  homepage "https://github.com/libfuse/libfuse"
  url "https://github.com/libfuse/libfuse/releases/download/fuse-3.18.3/fuse-3.18.3.tar.gz"
  sha256 "bcd19582c5e30f7fe45dd86a5540e998590aa01903afc7ebcbeea6c8ac5421ee"
  revision 2
  license all_of: [
    "LGPL-2.1-only", # include/, lib/
    "GPL-2.0-only",  # bin/, sbin/
  ]

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on macos: :golden_gate # FSKit v3

  def install
    # Portability fixes and the Darwin mount backend (lib/mount_darwin.c).
    system "patch", "-p1", "-i", Pathname(__dir__)/"patches/libfuse-3.18.3-darwin.patch"

    args = %w[
      -Dexamples=false
      -Dtests=false
      -Dutils=false
      -Duseroot=false
      -Denable-custom-io=true
    ]
    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def caveats
    <<~EOS
      Mounting needs the Fusetta FSKit extension and its fusermount3 helper:
        brew install --cask hsorbo/tap/fusetta
      then enable "Fusetta" in System Settings > General >
      Login Items & Extensions > File System Extensions.
    EOS
  end

  test do
    (testpath/"fuse-test.c").write <<~C
      #define FUSE_USE_VERSION 31
      #include <fuse3/fuse.h>
      #include <stdio.h>
      int main() {
        printf("%d%d\\n", FUSE_MAJOR_VERSION, FUSE_MINOR_VERSION);
        printf("%d\\n", fuse_version());
        return 0;
      }
    C
    system ENV.cc, "fuse-test.c", "-L#{lib}", "-I#{include}", "-D_FILE_OFFSET_BITS=64", "-lfuse3", "-o", "fuse-test"
    system "./fuse-test"
  end
end
