# The FSKit extension (inside Fusetta.app) that FUSE file systems mount
# through, and fusermount3, the helper libfuse runs to mount. Needs a Developer ID-signed, notarized release build; the url and
# sha256 below are filled in when one is published.
cask "fusetta" do
  version "0.1.0"
  sha256 :no_check

  url "https://github.com/hsorbo/fusetta/releases/download/v#{version}/Fusetta-#{version}.zip"
  name "Fusetta"
  desc "Open source FUSE implementation built on FSKit"
  homepage "https://github.com/hsorbo/fusetta"

  depends_on macos: :golden_gate

  app "Fusetta.app"
  # The mount helper libfuse runs (hsorbo/tap/libfuse).
  binary "#{appdir}/Fusetta.app/Contents/MacOS/fusermount3"

  caveats <<~EOS
    Enable "Fusetta" in System Settings > General >
    Login Items & Extensions > File System Extensions.
  EOS
end
