# The FSKit extension (inside Fusetta.app) that FUSE file systems mount
# through, and fusermount3, the helper libfuse runs to mount.
cask "fusetta" do
  version "0.1.0"
  sha256 "3e7775fc8da0323f348b5df4da7b3e7c0b2c51c5aede2ea42c2b4701414099af"

  url "https://github.com/hsorbo/fusetta/releases/download/v#{version}/Fusetta-#{version}.zip"
  name "Fusetta"
  desc "Open source FUSE implementation built on FSKit"
  homepage "https://github.com/hsorbo/fusetta"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :golden_gate

  app "Fusetta.app"
  # The mount helper libfuse runs (hsorbo/tap/libfuse).
  binary "#{appdir}/Fusetta.app/Contents/MacOS/fusermount3"

  caveats <<~EOS
    Enable "Fusetta" in System Settings > General >
    Login Items & Extensions > File System Extensions.
  EOS
end
