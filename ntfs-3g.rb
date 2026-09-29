# ntfs-3g from homebrew-core, built against libfuse from this tap (Fusetta
# mount backend) on macOS.
#
# patches/ntfs-3g-2026.9.18-fuse3.patch ports lowntfs-3g (the low-level
# driver) to libfuse 3. The high-level ntfs-3g driver is not built;
# bin/ntfs-3g is a link to lowntfs-3g.
class Ntfs3g < Formula
  desc "Read-write NTFS driver for FUSE"
  homepage "https://github.com/tuxera/ntfs-3g"
  url "https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2026.9.18.tgz"
  sha256 "bcf3cf301a79e42d330128ffb52d4cf615bd1d30c10a92d9d8d14f2bb4fcd9bf"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.0-or-later"]

  livecheck do
    url "https://github.com/tuxera/ntfs-3g.git"
    strategy :github_latest
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "hsorbo/tap/libfuse"
  depends_on macos: :golden_gate # FSKit v3

  def install
    # libfuse 3 port of lowntfs-3g (configure.ac and src/Makefile.am too).
    system "patch", "-p1", "-i", Pathname(__dir__)/"patches/ntfs-3g-2026.9.18-fuse3.patch"
    system "autoreconf", "--force", "--install", "--verbose"

    # ntfsprogs includes libintl.h when found, but never links libintl.
    args = %W[
      --exec-prefix=#{prefix}
      --mandir=#{man}
      --with-fuse=external
      --enable-extras
      --disable-ldconfig
      ac_cv_header_libintl_h=no
    ]
    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"

    bin.install_symlink "lowntfs-3g" => "ntfs-3g"
  end

  def caveats
    <<~EOS
      Mounting needs the Fusetta FSKit extension and its fusermount3 helper:
        brew install --cask hsorbo/tap/fusetta
      then enable "Fusetta" in System Settings > General >
      Login Items & Extensions > File System Extensions.

      macOS mounts NTFS read-only itself, and only root can read disk
      devices. To mount a partition read-write as yourself:
        diskutil list                     # find it, e.g. disk4s1
        diskutil unmount /dev/disk4s1
        sudo chown $USER /dev/disk4s1     # until the disk is replugged
        mkdir -p ~/mnt/ntfs
        ntfs-3g /dev/disk4s1 ~/mnt/ntfs
        umount ~/mnt/ntfs
      Use /dev/diskNsM, not /dev/rdiskNsM: raw devices need sector-aligned
      I/O, which libntfs-3g does not do.
    EOS
  end

  test do
    # create a small raw image, format and check it
    ntfs_raw = testpath/"ntfs.raw"
    File.open(ntfs_raw, "w") { |f| f.truncate(10 * 1024 * 1024) }
    ntfs_label_input = "Homebrew"
    system sbin/"mkntfs", "--force", "--fast", "--label", ntfs_label_input, ntfs_raw
    system bin/"ntfsfix", "--no-action", ntfs_raw
    assert_match ntfs_label_input, shell_output("#{sbin}/ntfslabel #{ntfs_raw}")
    assert_match "external FUSE 3", shell_output("#{bin}/ntfs-3g --version 2>&1")
  end
end
