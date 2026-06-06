# Formula for mori — shared memory layer for AI coding agents.
#
# Install:
#   brew tap fjwood69/mori
#   brew install mori
#   mori-setup
#
# Maintainer: fjwood69 <https://github.com/fjwood69>

class Mori < Formula
  include Language::Python::Virtualenv

  desc "Shared memory layer for AI coding agents (self-hosted, SQLite)"
  homepage "https://github.com/fjwood69/mori"

  # ── Release source ─────────────────────────────────────────────────────────
  # Update `url` and `sha256` each time a new mori version is tagged.
  # Compute SHA256: curl -sL <tarball-url> | sha256sum
  url "https://github.com/fjwood69/mori/archive/refs/tags/v2.2.12.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_v2.2.12_TARBALL"
  version "2.2.12"
  license "AGPL-3.0-only"

  # HEAD install (for testing from main branch):
  #   brew install --HEAD fjwood69/mori/mori
  head "https://github.com/fjwood69/mori.git", branch: "main"

  # ── Dependencies ───────────────────────────────────────────────────────────
  depends_on "python@3.13"

  # ── Install ────────────────────────────────────────────────────────────────
  def install
    # Create an isolated virtualenv for all Python dependencies.
    venv = virtualenv_create(libexec, "python3.13")

    # 1. Install runtime dependencies from requirements.txt.
    system libexec/"bin/pip", "install",
           "--require-virtualenv",
           "--no-cache-dir",
           "-r", "requirements.txt"

    # 2. Install the mori_advisor package itself (no deps — already installed above).
    system libexec/"bin/pip", "install",
           "--require-virtualenv",
           "--no-deps",
           "--no-cache-dir",
           buildpath

    # 3. Install the setup wizard and config template.
    bin.install "deploy/homebrew/mori-setup.sh" => "mori-setup"
    (etc/"mori").install "deploy/homebrew/mori.env.example" => "env.example"

    # 4. Install plugin installer scripts and skills for optional plugin wiring.
    (share/"mori").mkpath
    (share/"mori").install "skills"
    (share/"mori").install "scripts"

    # 5. Create the data directory.
    (var/"mori").mkpath
  end

  def post_install
    # Ensure log directory exists for the service.
    (var/"log").mkpath
  end

  # ── Service (launchd on macOS, systemd --user on Linux) ───────────────────
  # The server reads configuration from ~/.config/mori/env at startup
  # (via _load_user_env() in mori_advisor/main.py).
  # No environment variables are set here — the config file is the single
  # source of truth and avoids conflicts with the service unit.
  service do
    run [libexec/"bin/python", "-m", "mori_advisor.main"]
    keep_alive true
    log_path var/"log/mori.log"
    error_log_path var/"log/mori.log"
  end

  # ── Post-install instructions ─────────────────────────────────────────────
  def caveats
    <<~EOS
      Run the setup wizard to configure Mori and start the server:

        mori-setup

      The wizard will:
        • Prompt for your LLM provider URL and API key
        • Generate a server API key
        • Start the mori service (port 8968)
        • Optionally wire the Claude Code / Cursor plugin

      ──────────────────────────────────────────────────

      To manage the service manually:
        brew services start mori
        brew services stop mori
        brew services restart mori

      Logs:
        tail -f #{var}/log/mori.log

      Config file:
        ~/.config/mori/env

      Re-run the wizard at any time:
        mori-setup

      ──────────────────────────────────────────────────

      Linux note: for the service to persist after logout, run:
        loginctl enable-linger $USER
      (mori-setup will offer to do this automatically)
    EOS
  end

  test do
    # Smoke test: the package must import cleanly.
    system libexec/"bin/python", "-c", "import mori_advisor.main"
  end
end
