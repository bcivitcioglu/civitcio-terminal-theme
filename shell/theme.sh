# civitcio-terminal-theme — combined terminal + starship switcher
# shellcheck shell=bash
# Portable: macOS + Linux, bash + zsh. Installed by install.sh to
# ~/.config/civitcio-theme/theme.sh and sourced from ~/.bashrc / ~/.zshrc.
# dark bg + white pills | light bg + dark pills

_civitcio_palette() {
  [ -f "$HOME/.config/starship.toml" ] || return 0
  sed -i.bak "s/^palette = .*/palette = '$1'/" "$HOME/.config/starship.toml" 2>/dev/null
  rm -f "$HOME/.config/starship.toml.bak" 2>/dev/null
  return 0
}

# Width: short bar (default) vs full-width bar (--long).
# Short = [fill] disabled; long = [fill] enabled (painted bg:color_bg1).
_civitcio_fill() {
  # $1 = 'true' (short) | 'false' (full-width)
  _f="$HOME/.config/starship.toml"
  [ -f "$_f" ] || return 0
  if ! grep -q '^\[fill\]' "$_f" 2>/dev/null; then
    # pre-fill config (e.g. upgraded install): append the block
    printf '\n[fill]\nsymbol = %s\nstyle = "bg:color_bg1"\ndisabled = %s\n' "' '" "$1" >> "$_f"
    return 0
  fi
  sed -i.bak "/^\[fill\]/,/^disabled = / s/^disabled = .*/disabled = $1/" "$_f" 2>/dev/null
  rm -f "$_f.bak" 2>/dev/null
  return 0
}

_civitcio_is_macos() { [ "$(uname -s)" = "Darwin" ]; }

_civitcio_has_gnome_terminal() {
  command -v gsettings >/dev/null 2>&1 &&
    gsettings get org.gnome.Terminal.ProfilesList list >/dev/null 2>&1
}

# Fixed GNOME profile IDs (must match linux/gnome-terminal.sh)
_civitcio_gnome_dark_id() { printf '%s' '61c9d0a1-1c17-4d1e-a917-c4a1da9d0a1'; }
_civitcio_gnome_light_id() { printf '%s' '6fa9f0a1-fafa-4f9a-a9fa-ca11fa9f0a11'; }

_civitcio_gnome_default() {
  gsettings set org.gnome.Terminal.ProfilesList default "'$1'" >/dev/null 2>&1
}

# Flip Ghostty/Alacritty drop-in themes when the user config references them
_civitcio_ghostty() {
  _cfg="$HOME/.config/ghostty/config"
  [ -f "$_cfg" ] || return 0
  grep -q '^theme = calm-' "$_cfg" 2>/dev/null || return 0
  sed -i.bak "s/^theme = calm-.*/theme = calm-$1/" "$_cfg" 2>/dev/null
  rm -f "$_cfg.bak" 2>/dev/null
}

_civitcio_alacritty() {
  _cfg="$HOME/.config/alacritty/alacritty.toml"
  [ -f "$_cfg" ] || return 0
  grep -q 'calm-\(dark\|light\)' "$_cfg" 2>/dev/null || return 0
  sed -i.bak "s/calm-\(dark\|light\)/calm-$1/" "$_cfg" 2>/dev/null
  rm -f "$_cfg.bak" 2>/dev/null
}

theme-dark() {
  case "${1:-}" in
    ""|--short|-s) _fill='true'; _mode='short' ;;
    --long|-l) _fill='false'; _mode='full-width' ;;
    *) echo "usage: theme-dark [--short|--long]" >&2; return 1 ;;
  esac
  _civitcio_palette 'calm_white'
  _civitcio_fill "$_fill"
  if _civitcio_is_macos; then
    osascript -e 'tell application "Terminal" to set current settings of selected tab of front window to settings set "Calm-Dark"' 2>/dev/null || true
    osascript -e 'tell application "Terminal" to set default settings to settings set "Calm-Dark"' 2>/dev/null || true
  elif _civitcio_has_gnome_terminal; then
    _civitcio_gnome_default "$(_civitcio_gnome_dark_id)" || true
  fi
  _civitcio_ghostty 'dark' || true
  _civitcio_alacritty 'dark' || true
  echo "→ Calm-Dark: dark #1c1917 + starship calm_white ($_mode)"
}

theme-light() {
  case "${1:-}" in
    ""|--short|-s) _fill='true'; _mode='short' ;;
    --long|-l) _fill='false'; _mode='full-width' ;;
    *) echo "usage: theme-light [--short|--long]" >&2; return 1 ;;
  esac
  _civitcio_palette 'calm_dark'
  _civitcio_fill "$_fill"
  if _civitcio_is_macos; then
    osascript -e 'tell application "Terminal" to set current settings of selected tab of front window to settings set "Calm-Light"' 2>/dev/null || true
    osascript -e 'tell application "Terminal" to set default settings to settings set "Calm-Light"' 2>/dev/null || true
  elif _civitcio_has_gnome_terminal; then
    _civitcio_gnome_default "$(_civitcio_gnome_light_id)" || true
  fi
  _civitcio_ghostty 'light' || true
  _civitcio_alacritty 'light' || true
  echo "→ Calm-Light: off-white #fafaf9 + starship calm_dark ($_mode)"
}
