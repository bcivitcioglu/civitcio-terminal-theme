#!/usr/bin/env zsh
# demo script for Calm-Dark (white pills on warm black)
export STARSHIP_CONFIG="/Users/burak/civitcio-terminal-theme/demo/starship-dark.toml"
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
print "calm-dark — white pills on warm black #1c1917"
sleep 1.5
