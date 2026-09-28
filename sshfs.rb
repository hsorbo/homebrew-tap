# sshfs from homebrew-core, built against libfuse from this tap (Fusetta
# mount backend) on macOS.
class Sshfs < Formula
  desc "File system client based on SSH File Transfer Protocol"
  homepage "https://github.com/libfuse/sshfs"
  url "https://github.com/libfuse/sshfs/archive/refs/tags/sshfs-3.7.6.tar.gz"
  sha256 "67a3e166a39b07708497ee0aee308547dba386053cf8d816b4ce8a9b3066a6ce"
  license any_of: ["LGPL-2.1-only", "GPL-2.0-only"]

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "hsorbo/tap/libfuse"
  depends_on macos: :golden_gate # FSKit v3

  def install
    # The install script links mount.sshfs/mount.fuse.sshfs for Linux mount(8)
    # (with GNU ln --relative); macOS has no use for them.
    inreplace "meson.build", %r{^meson\.add_install_script\('utils/install_helper\.sh',.*?\)\n}m, ""
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system bin/"sshfs", "--version"
  end
end
