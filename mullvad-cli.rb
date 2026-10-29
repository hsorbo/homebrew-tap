# The `mullvad` command-line client. Talks to a running mullvad-daemon over /var/run/mullvad-vpn,
# whether that daemon comes from the mullvad-server formula or from the official Mullvad VPN app.
class MullvadCli < Formula
  desc "Command-line client for the Mullvad VPN daemon"
  homepage "https://mullvad.net"
  url "https://github.com/mullvad/mullvadvpn-app/archive/refs/tags/2026.5.tar.gz"
  sha256 "a133345d8d61f037d247ed89ff0dce823f652a7f25dea74f13a5029aa0374d23"
  license "GPL-3.0-only"
  head "https://github.com/mullvad/mullvadvpn-app.git", branch: "main"

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "mullvad-cli")

    # `mullvad shell-completions <shell> [dir]` writes a file into dir rather than printing to stdout.
    completions = buildpath/"completions"
    completions.mkpath
    %w[bash zsh fish].each { |sh| system bin/"mullvad", "shell-completions", sh, completions }
    bash_completion.install completions/"mullvad.bash" => "mullvad"
    zsh_completion.install completions/"_mullvad"
    fish_completion.install completions/"mullvad.fish"
  end

  def caveats
    <<~EOS
      Needs a running daemon: install mullvad-server from this tap, or the official app.

      If the official Mullvad VPN .pkg is installed, its postinstall symlinks
      share/fish/vendor_completions.d/mullvad.fish into the Homebrew prefix and
      `brew link` will refuse to overwrite it. To use this formula's completions instead:
        sudo rm #{HOMEBREW_PREFIX}/share/fish/vendor_completions.d/mullvad.fish
        brew link mullvad-cli
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mullvad --version")
  end
end
