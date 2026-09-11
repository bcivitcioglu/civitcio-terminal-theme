#!/usr/bin/env bash
# civitcio-terminal-theme — GNOME Terminal profiles (Calm-Dark / Calm-Light)
# Called by install.sh on Linux when GNOME Terminal schemas are present.
# Standalone: ./linux/gnome-terminal.sh [--dark|--light]  (default: --dark)
set -euo pipefail

DARK_ID="61c9d0a1-1c17-4d1e-a917-c4a1da9d0a1"
LIGHT_ID="6fa9f0a1-fafa-4f9a-a9fa-ca11fa9f0a11"
DEFAULT_MODE="${1:---dark}"

if ! command -v gsettings >/dev/null 2>&1; then
  echo "  gsettings not found — skipping GNOME Terminal profiles"
  exit 0
fi
if ! gsettings get org.gnome.Terminal.ProfilesList list >/dev/null 2>&1; then
  echo "  GNOME Terminal schemas not present — skipping profiles"
  exit 0
fi

# $1 = dconf profile path, rest = key=value pairs applied via gsettings
set_profile() {
  _path="$1"; shift
  while [ $# -gt 0 ]; do
    _kv="$1"; shift
    _k="${_kv%%=*}"; _v="${_kv#*=}"
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/Terminal/legacy/profiles:/:${_path}/" "$_k" "$_v"
  done
}

# 16-color ANSI ramp per theme (normal 0-7, bright 8-15)
DARK_PALETTE="['#292524', '#BC9B8D', '#87A087', '#D6D3D1', '#A8A29E', '#A8A29E', '#E7E5E4', '#E7E5E4', '#57534E', '#D8BCAF', '#A8C4A8', '#E7E5E4', '#D6D3D1', '#D6D3D1', '#FAFAF9', '#FFFFFF']"
LIGHT_PALETTE="['#44403C', '#A08476', '#5F7161', '#78716C', '#57534E', '#78716C', '#57534E', '#44403C', '#78716C', '#B49A8C', '#7FA083', '#57534E', '#44403C', '#57534E', '#44403C', '#292524']"

echo "  writing GNOME Terminal profile Calm-Dark"
set_profile "$DARK_ID" \
  "visible-name='Calm-Dark'" \
  "background-color='#1C1917'" \
  "foreground-color='#E7E5E4'" \
  "bold-color='#FAFAF9'" \
  "bold-color-same-as-fg=false" \
  "cursor-colors-set=true" \
  "cursor-background-color='#D6D3D1'" \
  "cursor-foreground-color='#1C1917'" \
  "highlight-colors-set=true" \
  "highlight-background-color='#78716C'" \
  "highlight-foreground-color='#E7E5E4'" \
  "palette=$DARK_PALETTE" \
  "use-theme-colors=false" \
  "use-theme-transparency=false" \
  "use-transparent-background=false" \
  "use-system-font=false" \
  "font='JetBrainsMono Nerd Font Mono 12'"

echo "  writing GNOME Terminal profile Calm-Light"
set_profile "$LIGHT_ID" \
  "visible-name='Calm-Light'" \
  "background-color='#FAFAF9'" \
  "foreground-color='#44403C'" \
  "bold-color='#292524'" \
  "bold-color-same-as-fg=false" \
  "cursor-colors-set=true" \
  "cursor-background-color='#44403C'" \
  "cursor-foreground-color='#FAFAF9'" \
  "highlight-colors-set=true" \
  "highlight-background-color='#D6D3D1'" \
  "highlight-foreground-color='#44403C'" \
  "palette=$LIGHT_PALETTE" \
  "use-theme-colors=false" \
  "use-theme-transparency=false" \
  "use-transparent-background=false" \
  "use-system-font=false" \
  "font='JetBrainsMono Nerd Font Mono 12'"

# Merge into profile list (keep any pre-existing profiles), set default
_cur="$(gsettings get org.gnome.Terminal.ProfilesList list)"
if [ "$_cur" = "@as []" ] || [ "$_cur" = "[]" ]; then
  _cur="['$DARK_ID']"
fi
for _id in "$DARK_ID" "$LIGHT_ID"; do
  case "$_cur" in *"$_id"*) ;; *) _cur="${_cur%]}, '$_id']}";; esac
done
gsettings set org.gnome.Terminal.ProfilesList list "$_cur"

if [ "$DEFAULT_MODE" = "--light" ]; then
  gsettings set org.gnome.Terminal.ProfilesList default "'$LIGHT_ID'"
  echo "  default → Calm-Light"
else
  gsettings set org.gnome.Terminal.ProfilesList default "'$DARK_ID'"
  echo "  default → Calm-Dark (run theme-light to flip)"
fi
