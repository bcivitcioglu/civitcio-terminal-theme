#!/usr/bin/env bash
# Regenerate assets/calm-{dark,light}[-long].gif (short + full-width bars)
# Requires: brew install asciinema agg starship
# Run from repo root: ./demo/render.sh
set -euo pipefail
cd "$(dirname "$0")/.."

asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-dark.sh" /tmp/calm-dark.cast
asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-dark.sh --long" /tmp/calm-dark-long.cast
asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-light.sh" /tmp/calm-light.cast
asciinema rec --overwrite --window-size 100x20 \
  --command "zsh demo/demo-light.sh --long" /tmp/calm-light-long.cast

agg --font-dir "$HOME/Library/Fonts" \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-dark --idle-time-limit 2 \
  /tmp/calm-dark.cast assets/calm-dark.gif

agg --font-dir "$HOME/Library/Fonts" \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-dark --idle-time-limit 2 \
  /tmp/calm-dark-long.cast assets/calm-dark-long.gif

agg --font-dir "$HOME/Library/Fonts" \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-light --idle-time-limit 2 \
  /tmp/calm-light.cast assets/calm-light.gif

agg --font-dir "$HOME/Library/Fonts" \
  --font-family "JetBrainsMono Nerd Font" --font-size 15 \
  --theme github-light --idle-time-limit 2 \
  /tmp/calm-light-long.cast assets/calm-light-long.gif

ls -lh assets/
