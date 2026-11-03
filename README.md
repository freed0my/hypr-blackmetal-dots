# hypr blackmetal dots

A minimalist monochrome Hyprland rice for Arch Linux: black background, thin borders, JetBrains Mono Nerd Font.

| | |
|---|---|
| WM | Hyprland |
| Bar | Waybar + eww volume mixer |
| Lockscreen | hyprlock (styled after the SDDM theme) |
| Login | SDDM, `blackmetal` theme |
| Launcher | rofi (monochrome icons are generated automatically) |
| Terminal | kitty |
| Notifications | dunst |
| Wallpapers | awww |
| GTK / cursor | `hypr-dots-black`, `Breeze-Rin` icons |
| Shell | zsh + oh-my-zsh + powerlevel10k |

## Installation

### Option 1: from the repository

```bash
git clone https://github.com/freed0my/hypr-blackmetal-dots.git
cd hypr-blackmetal-dots
./install.sh
```

### Option 2: single file

Download `rin-hypr-dots.sh` from [Releases](../../releases/latest) and run:

```bash
bash rin-hypr-dots.sh
```

### Flags

| flag | what it does |
|---|---|
| `-y` | don't ask any questions |
| `--no-pkgs` | configs only, skip package installation |
| `--no-zsh` | don't touch zsh / oh-my-zsh |

### What the installer does

1. Installs packages from the official repos (`pacman --needed`) and from the AUR (`eww`, `opentabletdriver`). If neither yay nor paru is present, it installs yay first.
2. Moves old configs to `~/.dots-backup-<date>` and copies the new ones.
3. Installs the GTK theme, cursor and SDDM theme into `/usr/share`, enables `sddm` and `NetworkManager`.
4. Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting.
5. Generates monochrome rofi icons for installed applications.

After installation, reboot and pick the Hyprland session in SDDM.

> **Monitors.** The config uses `DP-1` 1920x1080@240 with `HDMI-A-1` to its left. If yours differ, edit the `Monitor Setup` section in `~/.config/hypr/hyprland.conf` and `"output"` in `~/.config/waybar/config`. To list your monitors: `hyprctl monitors`.
>
> **NVIDIA.** The installer does not install drivers.

## Keybindings

| keys | action |
|---|---|
| `Super + Q` / `Super + Enter` | terminal (kitty) |
| `Alt + X` | rofi |
| `Super + E` | Thunar |
| `Super + C` | close window |
| `Alt + F` | fullscreen |
| `Super + Space` | toggle floating |
| `Super + L` | lock (hyprlock) |
| `Super + V` | screenshot region to clipboard |
| `Super + Shift + Print` | screenshot screen to clipboard |
| `Alt + 1…5` | workspaces 1–5 (DP-1) |
| `Super + 1…5` | workspaces 6–10 (HDMI-A-1) |
| `Super + Shift + 1…5` | move window to 1–5 |
| `Ctrl + Shift + 1…5` | move window to 6–10 |
| `Super + arrows` | move focus |
| `Super + Shift + arrows` | move window |
| `Super + Ctrl + arrows` | resize window |
| `Super + S` | scratchpad |
| `Super + Shift + K` | exit Hyprland |
| `Alt + Shift` | switch layout us / ru |

## Updating the repository

On your own machine, after changing configs:

```bash
./sync.sh                      # copies current configs into dots/
git add -A && git commit -m "update" && git push
./bundle.sh                    # builds rin-hypr-dots.sh
gh release create v$(date +%Y.%m.%d) rin-hypr-dots.sh --title "$(date +%F)" --notes ""
```

## Structure

```
install.sh        installer
sync.sh           system → dots/
bundle.sh         install.sh + dots/ → single file rin-hypr-dots.sh
dots/home/        everything copied into ~
dots/system/      GTK theme, cursor, SDDM theme (installed into /usr/share)
```
