#!/usr/bin/env bash
# civitcio-terminal-theme — one-line restore for terminal + starship (macOS + Linux)
# Usage (single line, same on both OSes):
#   curl -fsSL https://raw.githubusercontent.com/bcivitcioglu/civitcio-terminal-theme/main/install.sh | bash
# Or:
#   git clone https://github.com/bcivitcioglu/civitcio-terminal-theme.git && cd civitcio-terminal-theme && ./install.sh
#
# macOS:   Terminal.app profiles + starship + JetBrainsMono Nerd Font (via Homebrew)
# Linux:   GNOME Terminal profiles + Ghostty/Alacritty drop-ins + starship + Nerd Font
# Env override for testing: CIVITCIO_OS=darwin|linux
set -euo pipefail

REPO="bcivitcioglu/civitcio-terminal-theme"
RAW="https://raw.githubusercontent.com/${REPO}/main"
OS="${CIVITCIO_OS:-$(uname -s)}"
case "$OS" in
  [Dd]arwin*) OS="darwin" ;;
  [Ll]inux*) OS="linux" ;;
  *) echo "unsupported OS: $OS (need macOS or Linux)" >&2; exit 1 ;;
esac

WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo /tmp/civitcio-theme)"
TMPDL=""
NEED_DL=0
[ -f "${WORKDIR}/starship.toml" ] && [ -f "${WORKDIR}/shell/theme.sh" ] || NEED_DL=1

Dl() { curl -fsSL "$1" -o "$2"; }

if [ "${NEED_DL}" = "1" ]; then
  TMPDL="$(mktemp -d)"
  WORKDIR="${TMPDL}"
  echo "→ downloading theme files from ${RAW} ..."
  mkdir -p "${WORKDIR}/shell" "${WORKDIR}/terminal" "${WORKDIR}/linux/ghostty" "${WORKDIR}/linux/alacritty"
  Dl "${RAW}/starship.toml" "${WORKDIR}/starship.toml"
  Dl "${RAW}/shell/theme.sh" "${WORKDIR}/shell/theme.sh"
  if [ "$OS" = "darwin" ]; then
    Dl "${RAW}/terminal/Calm-Dark.terminal" "${WORKDIR}/terminal/Calm-Dark.terminal"
    Dl "${RAW}/terminal/Calm-Light.terminal" "${WORKDIR}/terminal/Calm-Light.terminal"
    Dl "${RAW}/Brewfile" "${WORKDIR}/Brewfile"
  else
    Dl "${RAW}/linux/gnome-terminal.sh" "${WORKDIR}/linux/gnome-terminal.sh"
    Dl "${RAW}/linux/ghostty/calm-dark" "${WORKDIR}/linux/ghostty/calm-dark"
    Dl "${RAW}/linux/ghostty/calm-light" "${WORKDIR}/linux/ghostty/calm-light"
    Dl "${RAW}/linux/alacritty/calm-dark.toml" "${WORKDIR}/linux/alacritty/calm-dark.toml"
    Dl "${RAW}/linux/alacritty/calm-light.toml" "${WORKDIR}/linux/alacritty/calm-light.toml"
  fi
fi

ensure_line() {
  # $1 = file, $2.. = lines to append (once) — creates parent file if needed
  _f="$1"; shift
  touch "$_f"
  _line="$*"
  grep -Fqx "$_line" "$_f" 2>/dev/null || printf '%s\n' "$_line" >> "$_f"
}

deps_darwin() {
  echo "→ 1/4 deps (Homebrew, starship, nerd font)"
  if ! command -v brew >/dev/null 2>&1; then
    echo "  Homebrew missing — installing (may ask for sudo)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  fi
  brew install starship 2>/dev/null || brew upgrade starship 2>/dev/null || true
  brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
}

deps_linux() {
  echo "→ 1/5 deps (starship, nerd font)"
  for _t in curl unzip fc-cache; do
    if ! command -v "$_t" >/dev/null 2>&1; then
      echo "  missing '$_t' — install it first, e.g.:"
      echo "    Ubuntu/Debian: sudo apt install curl unzip fontconfig"
      echo "    Fedora:        sudo dnf install curl unzip fontconfig"
      echo "    Arch:          sudo pacman -S curl unzip fontconfig"
      exit 1
    fi
  done
  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/fonts"
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
    echo "  adding ~/.local/bin to PATH (bashrc/zshrc)"
    ensure_line "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
    ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
    export PATH="$HOME/.local/bin:$PATH" ;;
  esac
  if ! command -v starship >/dev/null 2>&1; then
    echo "  installing starship to ~/.local/bin (no sudo needed)"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
  else
    echo "  starship already installed ($(starship --version | head -1))"
  fi
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd"; then
    echo "  JetBrainsMono Nerd Font already installed"
  else
    echo "  downloading JetBrainsMono Nerd Font..."
    _zip="$(mktemp -d)/JetBrainsMono.zip"
    curl -fsSL -o "$_zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o -j "$_zip" '*NerdFontMono-Regular.ttf' '*NerdFontMono-Bold.ttf' '*NerdFont-Regular.ttf' '*NerdFont-Bold.ttf' -d "$HOME/.local/share/fonts" >/dev/null
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null
    echo "  fonts installed to ~/.local/share/fonts"
  fi
}

install_starship() {
  if [ "$OS" = "darwin" ]; then echo "→ 2/4 starship config"; else echo "→ 2/5 starship config"; fi
  mkdir -p "$HOME/.config"
  if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" "/tmp/starship.toml.backup.$(date +%s)"
    echo "  backup: /tmp/starship.toml.backup.*"
  fi
  cp "${WORKDIR}/starship.toml" "$HOME/.config/starship.toml"
  if command -v starship >/dev/null 2>&1; then
    starship print-config >/dev/null && echo "  starship.toml valid (calm_white + calm_dark)"
  fi
}

migrate_legacy_inline() {
  # $1 = rc file. Pre-loader installs defined theme-dark()/theme-light()
  # inline; those shadow ~/.config/civitcio-theme/theme.sh forever (and never
  # learned --long). Replace them with the loader so reinstalls heal.
  _rc="$1"
  [ -f "$_rc" ] || return 0
  grep -q '^theme-dark()' "$_rc" 2>/dev/null || return 0
  grep -q 'civitcio-theme/theme.sh' "$_rc" 2>/dev/null && return 0
  cp "$_rc" "$_rc.pre-civitcio-migrate.bak" 2>/dev/null || true
  _tmp="$(mktemp)"
  sed -e '/^theme-dark()/,/^}/d' -e '/^theme-light()/,/^}/d' "$_rc" > "$_tmp" \
    && cat "$_tmp" > "$_rc"
  rm -f "$_tmp"
  grep -q '^# Calm theme switcher' "$_rc" 2>/dev/null && \
    sed -i.bak '/^# Calm theme switcher/,+1d' "$_rc" 2>/dev/null || true
  rm -f "$_rc.bak" 2>/dev/null
  echo "  migrated legacy inline switcher in $_rc (backup: $_rc.pre-civitcio-migrate.bak)"
}

install_shell() {
  if [ "$OS" = "darwin" ]; then echo "→ 3/4 shell switcher (theme-dark / theme-light)"; else echo "→ 3/5 shell switcher (theme-dark / theme-light)"; fi
  mkdir -p "$HOME/.config/civitcio-theme"
  cp "${WORKDIR}/shell/theme.sh" "$HOME/.config/civitcio-theme/theme.sh"
  _loader='[ -f "$HOME/.config/civitcio-theme/theme.sh" ] && . "$HOME/.config/civitcio-theme/theme.sh"'
  if [ "$OS" = "darwin" ]; then
    touch "$HOME/.zshrc"
    migrate_legacy_inline "$HOME/.zshrc"
    if ! grep -q 'civitcio-theme/theme.sh' "$HOME/.zshrc" 2>/dev/null; then
      printf '\n# civitcio-terminal-theme\n%s\n' "$_loader" >> "$HOME/.zshrc"
      echo "  loader added to ~/.zshrc"
    else
      echo "  switcher already in ~/.zshrc (skip)"
    fi
    if ! grep -q 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
      echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    fi
  else
    for _rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
      _shell="$(basename "$_rc" | sed 's/^\.//')"
      touch "$_rc"
      migrate_legacy_inline "$_rc"
      if ! grep -q 'civitcio-theme/theme.sh' "$_rc" 2>/dev/null; then
        printf '\n# civitcio-terminal-theme\n%s\n' "$_loader" >> "$_rc"
        echo "  loader added to $_rc"
      else
        echo "  switcher already in $_rc (skip)"
      fi
      if [ "$_shell" = "bash" ]; then
        grep -q 'starship init bash' "$_rc" 2>/dev/null || echo 'eval "$(starship init bash)"' >> "$_rc"
      else
        grep -q 'starship init zsh' "$_rc" 2>/dev/null || echo 'eval "$(starship init zsh)"' >> "$_rc"
      fi
    done
  fi
}

install_terminal_macos() {
  echo "→ 4/4 Terminal.app profiles (Calm-Dark, Calm-Light)"
  python3 - "${WORKDIR}" <<'PY'
import plistlib, subprocess, sys, os, tempfile
workdir = sys.argv[1]
data = subprocess.check_output(['defaults','export','com.apple.Terminal','-'])
tmp = tempfile.mktemp(suffix='.plist')
open(tmp,'wb').write(data)
d = plistlib.load(open(tmp,'rb'))
for name in ['Calm-Dark','Calm-Light']:
    src = os.path.join(workdir, 'terminal', f'{name}.terminal')
    with open(src,'rb') as f:
        prof = plistlib.load(f)
    prof['name'] = name
    d['Window Settings'][name] = prof
    print(f'  imported {name}')
d['Default Window Settings'] = 'Calm-Dark'
d['Startup Window Settings'] = 'Calm-Dark'
out = tempfile.mktemp(suffix='.plist')
with open(out,'wb') as f:
    plistlib.dump(d, f)
subprocess.check_call(['defaults','import','com.apple.Terminal', out])
print('  default → Calm-Dark (run theme-light to flip)')
PY
}

install_terminal_linux() {
  echo "→ 4/5 terminal profiles"
  if [ -f "${WORKDIR}/linux/gnome-terminal.sh" ]; then
    bash "${WORKDIR}/linux/gnome-terminal.sh" --dark || true
  fi
  mkdir -p "$HOME/.config/ghostty/themes" "$HOME/.config/alacritty/themes"
  for _t in calm-dark calm-light; do
    [ -f "${WORKDIR}/linux/ghostty/${_t}" ] && cp "${WORKDIR}/linux/ghostty/${_t}" "$HOME/.config/ghostty/themes/${_t}"
    [ -f "${WORKDIR}/linux/alacritty/${_t}.toml" ] && cp "${WORKDIR}/linux/alacritty/${_t}.toml" "$HOME/.config/alacritty/themes/${_t}.toml"
  done
  echo "  Ghostty/Alacritty drop-ins → ~/.config/ghostty/themes + ~/.config/alacritty/themes"
  echo "  (theme-dark/theme-light flips them when your config references calm-dark/calm-light)"
}

echo "civitcio-terminal-theme — OS: $OS"
if [ "$OS" = "darwin" ]; then
  deps_darwin
  install_starship
  install_shell
  install_terminal_macos
  echo ""
  echo "✓ done. Restart Terminal (Cmd+Q, reopen), then:"
else
  deps_linux
  install_starship
  install_shell
  install_terminal_linux
  echo ""
  echo "→ 5/5 reload your shell: exec zsh  (or exec bash), then:"
fi
echo "  theme-dark   # dark #1c1917 + white pills"
echo "  theme-light  # off-white #fafaf9 + dark pills"
[ -n "${TMPDL}" ] && rm -rf "${TMPDL}"
