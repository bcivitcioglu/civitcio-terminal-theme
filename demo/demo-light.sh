#!/usr/bin/env zsh
# demo script for Calm-Light (dark pills on off-white)
# usage: zsh demo/demo-light.sh [--long]
_repo="${0:A:h}/.."
_base="$_repo/demo/starship-light.toml"
_cfg="$_base"
if [[ "${1:-}" == "--long" ]]; then
  # full-width variant: same config with the [fill] module enabled
  _cfg="$(mktemp /tmp/calm-light-long.XXXXXX.toml)"
  sed "/^\[fill\]/,/^disabled = / s/^disabled = .*/disabled = false/" "$_base" > "$_cfg"
  trap 'rm -f "$_cfg"' EXIT
fi
export STARSHIP_CONFIG="$_cfg"
export TERM="xterm-256color"
export CLICOLOR=1
cd "$_repo"
print -P "$(starship prompt)"
print ""
sleep 0.6
print -P "%B$%b ls"
ls
sleep 1.2
print -P "$(starship prompt)"
print ""
sleep 0.4
print -P "%B$%b git status --short --branch"
git status --short --branch 2>/dev/null || echo "## main"
sleep 1.2
print -P "$(starship prompt)"
print ""
sleep 0.4
print "calm-light — dark pills on off-white #fafaf9"
sleep 1.5
