# Headless Mullvad VPN: the system daemon and its helper tools, without the Electron GUI.
# The daemon must run as root; start it with `sudo brew services start mullvad-server`.
# Control it with the `mullvad` CLI from the mullvad-cli formula.
class MullvadServer < Formula
  desc "VPN daemon for Mullvad, without the GUI"
  homepage "https://mullvad.net"
  url "https://github.com/mullvad/mullvadvpn-app/archive/refs/tags/2026.5.tar.gz"
  sha256 "a133345d8d61f037d247ed89ff0dce823f652a7f25dea74f13a5029aa0374d23"
  license "GPL-3.0-only"
  head "https://github.com/mullvad/mullvadvpn-app.git", branch: "main"

  depends_on "protobuf" => :build
  depends_on "rust" => :build
  depends_on :macos

  conflicts_with cask: "mullvad-vpn", because: "both install the daemon and own /var/run/mullvad-vpn"

  def install
    # One `cargo build` for all three binaries; `cargo install *std_cargo_args` would mean three
    # separate builds since it takes a single --path.
    system "cargo", "build", "--release", "--locked",
           "-p", "mullvad-daemon", "--bin", "mullvad-daemon",
           "-p", "mullvad-setup", "--bin", "mullvad-setup",
           "-p", "mullvad-problem-report", "--bin", "mullvad-problem-report"
    bin.install %w[mullvad-daemon mullvad-setup mullvad-problem-report].map { |b| "target/release/#{b}" }

    # The daemon reads relays.json from MULLVAD_RESOURCE_DIR as its initial relay list.
    pkgshare.install "dist-assets/relays/relays.json"
  end

  service do
    run [opt_bin/"mullvad-daemon", "-v"]
    require_root true
    keep_alive true
    environment_variables MULLVAD_RESOURCE_DIR:            opt_pkgshare,
                          MULLVAD_MANAGEMENT_SOCKET_GROUP: "admin"
    log_path var/"log/mullvad-daemon.log"
    error_log_path var/"log/mullvad-daemon.log"
  end

  def caveats
    <<~EOS
      The daemon needs root. Start it with:
        sudo brew services start mullvad-server

      Control it with the `mullvad` CLI:
        brew install mullvad-cli

      Split tunneling needs Full Disk Access for:
        #{opt_bin}/mullvad-daemon

      Lockdown mode keeps pf rules after the daemon stops. To clear them:
        sudo mullvad-setup reset-firewall
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mullvad-daemon --version")
  end
end
