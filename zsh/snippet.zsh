# Civitcio theme snippet — append to ~/.zshrc (handled by install.sh)
# Combined Terminal.app profile + starship palette switcher

# Ensure starship is initialized (skip if already present)
if ! grep -q 'starship init zsh' ~/.zshrc 2>/dev/null; then
  eval "$(starship init zsh)"
fi

# dark bg + white pills | light bg + dark pills
theme-dark() {
  sed -i '' "s/^palette = .*/palette = 'calm_white'/" ~/.config/starship.toml
  osascript -e 'tell application "Terminal" to set current settings of selected tab of front window to settings set "Calm-Dark"' 2>/dev/null
  osascript -e 'tell application "Terminal" to set default settings to settings set "Calm-Dark"' 2>/dev/null
  echo "→ Calm-Dark: Terminal #1c1917 + starship calm_white"
}
theme-light() {
  sed -i '' "s/^palette = .*/palette = 'calm_dark'/" ~/.config/starship.toml
  osascript -e 'tell application "Terminal" to set current settings of selected tab of front window to settings set "Calm-Light"' 2>/dev/null
  osascript -e 'tell application "Terminal" to set default settings to settings set "Calm-Light"' 2>/dev/null
  echo "→ Calm-Light: Terminal #fafaf9 + starship calm_dark"
}
