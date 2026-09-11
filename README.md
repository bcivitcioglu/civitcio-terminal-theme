# civitcio-terminal-theme

Calm dual theme for **Apple Terminal + [starship](https://starship.rs)**. Same powerline look, two moods:

| Calm-Dark — dark `#1c1917` + white pills | Calm-Light — off-white `#fafaf9` + dark pills |
| --- | --- |
| ![Calm-Dark](assets/calm-dark.gif) | ![Calm-Light](assets/calm-light.gif) |

> GIF backgrounds are approximate (rendered with agg's github-dark/light).
> The exact Terminal colors ship as `terminal/*.terminal` profiles.

## Restore in one line

```sh
curl -fsSL https://raw.githubusercontent.com/bcivitcioglu/civitcio-terminal-theme/main/install.sh | bash
```

Then fully quit Terminal (`Cmd+Q`), reopen, and switch:

```sh
theme-dark   # dark #1c1917 + starship calm_white
theme-light  # off-white #fafaf9 + starship calm_dark
```

Or clone and run locally:

```sh
git clone https://github.com/bcivitcioglu/civitcio-terminal-theme.git
cd civitcio-terminal-theme
./install.sh
```

## What's inside

| File | Installs to |
| --- | --- |
| `starship.toml` | `~/.config/starship.toml` (palettes `calm_white`, `calm_dark`; `gruvbox_dark` kept) |
| `terminal/Calm-Dark.terminal` | Terminal profile, warm-black bg `#1c1917`, soft-white text |
| `terminal/Calm-Light.terminal` | Terminal profile, off-white bg `#fafaf9`, dark-gray text |
| `zsh/snippet.zsh` | `theme-dark` / `theme-light` switchers appended to `~/.zshrc` |
| `Brewfile` | `starship` + `font-jetbrains-mono-nerd-font` |
| `demo/` | scripts + tapes to regenerate the GIFs (`./demo/render.sh`) |

`install.sh` backs up your existing `~/.config/starship.toml` to `/tmp/starship.toml.backup.*`
and sets `Calm-Dark` as the default Terminal profile.

## Requirements

- macOS + Apple Terminal
- [Homebrew](https://brew.sh) (installed automatically if missing)
- A Nerd Font (installed via Brewfile) — prompts use ``  󰀵   glyphs

## Revert

```sh
# starship: set palette back, e.g.
sed -i '' "s/^palette = .*/palette = 'gruvbox_dark'/" ~/.config/starship.toml
# terminal: Settings > Profiles > pick your old profile as Default
```
