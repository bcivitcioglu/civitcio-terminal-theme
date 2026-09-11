#!/usr/bin/env bash
# civitcio-terminal-theme — one-line restore for Terminal + starship
# Usage (single line):
#   curl -fsSL https://raw.githubusercontent.com/bcivitcioglu/civitcio-terminal-theme/main/install.sh | bash
# Or:
#   git clone https://github.com/bcivitcioglu/civitcio-terminal-theme.git && cd civitcio-terminal-theme && ./install.sh
set -euo pipefail

REPO="bcivitcioglu/civitcio-terminal-theme"
RAW="https://raw.githubusercontent.com/${REPO}/main"
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo /tmp/civitcio-theme)"
TMPDL=""
NEED_DL=0
[ -f "${WORKDIR}/starship.toml" ] || NEED_DL=1

if [ "${NEED_DL}" = "1" ]; then
  TMPDL="$(mktemp -d)"
  WORKDIR="${TMPDL}"
  echo "→ downloading theme files from ${RAW} ..."
  curl -fsSL "${RAW}/starship.toml" -o "${WORKDIR}/starship.toml"
  mkdir -p "${WORKDIR}/terminal" "${WORKDIR}/zsh"
  curl -fsSL "${RAW}/terminal/Calm-Dark.terminal" -o "${WORKDIR}/terminal/Calm-Dark.terminal"
  curl -fsSL "${RAW}/terminal/Calm-Light.terminal" -o "${WORKDIR}/terminal/Calm-Light.terminal"
  curl -fsSL "${RAW}/zsh/snippet.zsh" -o "${WORKDIR}/zsh/snippet.zsh"
  curl -fsSL "${RAW}/Brewfile" -o "${WORKDIR}/Brewfile"
fi

echo "→ 1/4 deps (brew, starship, nerd font)"
if ! command -v brew >/dev/null 2>&1; then
  echo "  Homebrew missing — installing (may ask for sudo)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
fi
brew install starship 2>/dev/null || brew upgrade starship 2>/dev/null || true
brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true

echo "→ 2/4 starship config"
mkdir -p ~/.config
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml "/tmp/starship.toml.backup.$(date +%s)" && echo "  backup: /tmp/starship.toml.backup.*"
cp "${WORKDIR}/starship.toml" ~/.config/starship.toml
starship print-config >/dev/null && echo "  starship.toml valid (calm_white + calm_dark)"

echo "→ 3/4 zsh switcher (theme-dark / theme-light)"
touch ~/.zshrc
if ! grep -q 'theme-dark()' ~/.zshrc 2>/dev/null; then
  printf '\n# civitcio-terminal-theme\n' >> ~/.zshrc
  cat "${WORKDIR}/zsh/snippet.zsh" >> ~/.zshrc
  echo "  appended snippet to ~/.zshrc"
else
  echo "  snippet already in ~/.zshrc (skip)"
fi
if ! grep -q 'starship init zsh' ~/.zshrc 2>/dev/null; then
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

echo "→ 4/4 Terminal.app profiles (Calm-Dark, Calm-Light)"
python3 - "${WORKDIR}" <<'PY'
import plistlib, subprocess, sys, os
workdir = sys.argv[1]
import tempfile
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

echo ""
echo "✓ done. Restart Terminal (Cmd+Q, reopen), then:"
echo "  theme-dark   # dark #1c1917 + white pills"
echo "  theme-light  # off-white #fafaf9 + dark pills"
[ -n "${TMPDL}" ] && rm -rf "${TMPDL}"
