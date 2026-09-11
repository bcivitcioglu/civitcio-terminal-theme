#!/usr/bin/env zsh
# demo script for Calm-Light (dark pills on off-white)
export STARSHIP_CONFIG="/Users/burak/civitcio-terminal-theme/demo/starship-light.toml"
export TERM="xterm-256color"
export CLICOLOR=1
cd "/Users/burak/civitcio-terminal-theme"
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
