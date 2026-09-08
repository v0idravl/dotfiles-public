```text
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
  debian wayland desktop starter · sway + tmux + nvim · kanagawa-dragon
```

![os](https://img.shields.io/badge/debian-wayland-A81D33?logo=debian&logoColor=white)
![wm](https://img.shields.io/badge/wm-sway%20%2B%20waybar-68752A?logo=sway&logoColor=white)
![deps](https://img.shields.io/badge/dependencies-none%20tracked%2C%20shell%20only-44CC11)
![license](https://img.shields.io/badge/license-MIT-89E051)

A minimal, plaintext-forward Debian (Wayland) desktop starter: **sway +
waybar + fuzzel + mako + swaylock + alacritty + zsh + tmux + neovim**,
themed end-to-end with **kanagawa-dragon**, plus a live theme switcher
(`theme-set`) that flips the whole desktop between the default dragon look
and a low-light red-on-black **redlight** mode.

This is a curated, neutral base — clone it, read it, take what you want.
It is deliberately small; nothing here needs sudo or touches the system
outside `$HOME`.

---

## ⚡ 30-second demo

```bash
git clone https://github.com/v0idravl/dotfiles-public.git ~/dotfiles-public
cd ~/dotfiles-public

./deploy.sh --dry-run   # preview exactly what would be linked; touches nothing
./deploy.sh             # back up existing files, then symlink everything

# generate every theme fragment, then flip to low-light mode
theme-set dragon
theme-set redlight
```

---

## 🎯 Purpose

Most dotfiles repos are a pile of loosely related configs. This one is a
coherent starting point with one rule that holds everywhere: **no hex
values are hardcoded in app configs**. Every color flows from the two
palette blocks in `theme-set`. It focuses on:

- a complete, working sway desktop you can clone onto a fresh Debian install
- a single source of truth for theming, switchable live without logging out
- plaintext configs that stay readable — no frameworks, no generators
- graceful degradation: every optional extra (eza, bat, fzf, zsh plugins)
  is guarded, so a bare system still works
- staying inside `$HOME` — nothing here needs root or writes elsewhere

---

## 🗺️ Layout

The tree mirrors `$HOME`:

```text
deploy.sh                     the installer: backup-then-symlink into $HOME (no sudo)
.zshrc                        prompt + session extras; sources .config/zsh/common.zsh
.tmux.conf                    prefix (C-a), wl-copy clipboard; sources .config/tmux/common.conf
.config/zsh/common.zsh        shell core: history, completion, aliases, fzf, plugins
.config/tmux/common.conf      tmux core: splits, vim pane nav, copy-mode scrolling
.config/alacritty/alacritty.toml
.config/sway/config           minimal sway: keys, workspaces, outputs, autostart
.config/waybar/               two-bar setup (laptop panel + external), style.css
.config/fuzzel/base.ini       launcher, non-color settings
.config/mako/base.conf        notifications, non-color settings
.config/swaylock/base.conf    lock screen, non-color settings
.config/nvim/                 lazy.nvim config + redlight.vim colorscheme
.local/bin/theme-set          the live dragon <-> redlight switcher
.local/bin/set-wallpaper      install an image as ~/Pictures/wallpaper.png
.local/bin/waybar-run         flock-guarded waybar supervisor (one bar, always)
.local/bin/shinbun            (optional) world news over Tor — pinned clone installed by deploy.sh
```

---

## 📥 Installation

### Requirements

Packages you'll want on Debian:

```bash
sudo apt install sway waybar fuzzel mako-notifier swaylock swayidle \
  alacritty zsh tmux neovim wl-clipboard grim slurp brightnessctl \
  alsa-utils fonts-terminess-ttf
```

or install Terminess Nerd Font from nerdfonts.com — the configs expect
"Terminess Nerd Font". Optional shell extras: `eza`, `bat`, `fzf`,
`zsh-syntax-highlighting`, `zsh-autosuggestions` (all guarded; everything
degrades gracefully without them).

### Link into place

`deploy.sh` backs up any existing files to `~/.dotfiles-backup/<timestamp>/`,
then symlinks everything the repo ships into `$HOME`. It is idempotent
(re-running just replaces its own symlinks), needs no sudo, and touches
nothing outside `$HOME`:

```bash
git clone https://github.com/v0idravl/dotfiles-public.git ~/dotfiles-public
cd ~/dotfiles-public

./deploy.sh --dry-run   # show exactly what would be linked; touches nothing
./deploy.sh             # back up + symlink
```

It also installs the optional extras (see shinbun in the layout above) as
pinned clones. To uninstall: delete the symlinks (`find ~ -lname "$PWD/*"`
lists them) and restore what you want from the backup dir.

Or by hand — symlinks (edits in the repo apply immediately; stow works too):

```bash
ln -s "$PWD/.zshrc"       ~/.zshrc
ln -s "$PWD/.tmux.conf"   ~/.tmux.conf
for d in zsh tmux alacritty sway waybar fuzzel mako swaylock nvim; do
  ln -s "$PWD/.config/$d" ~/.config/$d
done
mkdir -p ~/.local/bin
for s in theme-set set-wallpaper waybar-run; do
  ln -s "$PWD/.local/bin/$s" ~/.local/bin/$s
done

# option B: plain copies (cp -r instead of ln -s) if you want to fork freely
```

Then generate the theme fragments once:

```bash
theme-set dragon
```

---

## 🎨 The theme system

`theme-set` is the single source of truth for every color — the two palette
blocks at the top of `.local/bin/theme-set` (`dragon`, `redlight`). Never
hardcode hex values in app configs; two integration patterns instead:

- **include pattern** — sway, waybar, alacritty, tmux and zsh source a
  **generated** fragment next to their tracked config
  (`~/.config/sway/theme.conf`, `~/.config/waybar/theme.css`,
  `~/.config/alacritty/theme.toml`, `~/.config/tmux/theme.conf`,
  `~/.config/zsh/theme.zsh`).
- **generate pattern** — mako, fuzzel and swaylock can't include files, so
  their non-color settings live in the tracked `base.conf`/`base.ini` and
  theme-set concatenates base + generated colors into the app's real config
  path (`~/.config/mako/config`, `~/.config/fuzzel/fuzzel.ini`,
  `~/.config/swaylock/config`).

**The generated fragments are NOT tracked in this repo** — they are written
into `$HOME` by theme-set. After installing, run:

```bash
theme-set dragon      # generate every fragment (first run)
theme-set redlight    # low-light red-on-black; wallpaper drops to black
theme-set toggle      # flip
theme-set --auto      # pick by the clock (default window 19:00-06:00,
                      # override with THEME_RED_START / THEME_RED_END)
```

Everything switches live: sway reloads, waybar restyles on SIGUSR2, alacritty
watches its import, tmux re-sources its fragment, running nvim instances get
`:colorscheme` over their sockets, and redlight additionally floors the
backlight (restored on dragon). Every reload is guarded, so `theme-set` is
safe to run headless or over SSH; set `THEME_SET_NO_RELOAD=1` to skip all
live pokes entirely.

nvim's redlight colorscheme (`colors/redlight.vim`) is plugin-free, so it
works even before lazy.nvim finishes its first install; dragon comes from
`rebelot/kanagawa.nvim`.

---

## ⚠️ Known Limitations

- The sway config pins a two-output layout (`eDP-1` + `HDMI-A-2`) and the
  waybar thermal zone is machine-specific — check `swaymsg -t get_outputs`
  and `/sys/class/thermal/thermal_zone*/type` on your hardware and adjust.
- Volume keys and the bar's volume module talk to ALSA directly (`amixer`).
  If you run PipeWire/PulseAudio instead, swap them for `wpctl`/`pactl`.

---

## 📝 Notes

- `.zshrc` auto-attaches every new terminal to a tmux session named
  `default`; delete that block if that's not for you. Machine-specific
  extras belong in `~/.zshrc.local` (sourced if present).

---

## 📄 License

MIT — see [LICENSE](LICENSE).
