# civitcio-terminal-theme — legacy snippet path (kept for compatibility)
# shellcheck shell=bash
# New installs use shell/theme.sh (copied to ~/.config/civitcio-theme/theme.sh
# and sourced from ~/.bashrc / ~/.zshrc). Sourcing this file directly also works
# when run from a repo checkout:
#   source civitcio-terminal-theme/zsh/snippet.zsh
if [ -f "$HOME/.config/civitcio-theme/theme.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.config/civitcio-theme/theme.sh"
else
  _here=""
  if [ -n "${BASH_SOURCE:-}" ]; then
    _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
  elif [ -n "${ZSH_VERSION:-}" ]; then
    eval '_here="$(cd "$(dirname "${(%):-%x}")" 2>/dev/null && pwd || echo "")"'
  fi
  if [ -n "$_here" ] && [ -f "$_here/../shell/theme.sh" ]; then
    # shellcheck disable=SC1091
    . "$_here/../shell/theme.sh"
  fi
  unset _here
fi
