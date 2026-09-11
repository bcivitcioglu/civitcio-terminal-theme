#!/usr/bin/env bash
# Regenerate assets/calm-dark.gif + assets/calm-light.gif
# Requires: brew install asciinema agg starship
# Run from repo root: ./demo/render.sh
set -euo pipefail
cd "$(dirname "$0")/.."

asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-dark.sh" /tmp/calm-dark.cast
asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-light.sh" /tmp/calm-light.cast

agg --font-dir /Users/burak/Library/Fonts \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-dark --idle-time-limit 2 \
  /tmp/calm-dark.cast assets/calm-dark.gif

agg --font-dir /Users/burak/Library/Fonts \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-light --idle-time-limit 2 \
  /tmp/calm-light.cast assets/calm-light.gif

ls -lh assets/
