# homebrew-mori

Homebrew tap for [mori](https://github.com/fjwood69/mori) — shared memory layer for AI coding agents.

## Install

```bash
brew tap fjwood69/mori
brew install mori
mori-setup
```

The `mori-setup` wizard configures your LLM provider, generates a server API key, starts the server on `localhost:8968`, and optionally wires the Claude Code / Cursor plugin.

## What gets installed

| Component | Location |
|-----------|----------|
| Python venv + dependencies | `$(brew --prefix)/opt/mori/libexec/` |
| Setup wizard | `$(brew --prefix)/bin/mori-setup` |
| Skills + installer scripts | `$(brew --prefix)/share/mori/` |
| Config template | `$(brew --prefix)/etc/mori/env.example` |
| Your config | `~/.config/mori/env` |
| Your memories (SQLite) | `~/.local/share/mori/` |
| Service logs | `$(brew --prefix)/var/log/mori.log` |

## Service management

```bash
brew services start mori     # start
brew services stop mori      # stop
brew services restart mori   # restart after config changes
```

The service reads `~/.config/mori/env` on startup. Edit that file and restart to apply changes.

## Linux

Homebrew on Linux uses `systemd --user` units. For the service to persist after logout:

```bash
loginctl enable-linger $USER
```

`mori-setup` will offer to do this automatically.

## Configuration

Edit `~/.config/mori/env` — see `$(brew --prefix)/etc/mori/env.example` for all available options. Restart the service after editing.

## Updating

```bash
brew upgrade mori
brew services restart mori
```

## Uninstall

```bash
brew services stop mori
brew uninstall mori
brew untap fjwood69/mori
# Your config + memories are untouched at ~/.config/mori/ and ~/.local/share/mori/
```

## License

mori is [AGPL-3.0](https://github.com/fjwood69/mori/blob/main/LICENSE). Every instance is the user's own — no shared infrastructure, no phone-home.
