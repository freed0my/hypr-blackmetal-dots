<div align="center">

#  hypr blackmetal dots 

**A minimalist monochrome Hyprland rice for Arch Linux.**
Black stone, old silver, wine and muted violet. No neon, no noise.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-0a0a0a?style=for-the-badge&logo=archlinux&logoColor=c4c0c4)
![Hyprland](https://img.shields.io/badge/Hyprland-0a0a0a?style=for-the-badge&logo=hyprland&logoColor=c4c0c4)
![Shell](https://img.shields.io/badge/zsh-0a0a0a?style=for-the-badge&logo=gnubash&logoColor=c4c0c4)
![Font](https://img.shields.io/badge/JetBrains_Mono_NF-0a0a0a?style=for-the-badge&logoColor=c4c0c4)

[Installation](#-installation) ·
[Palette](#-palette) ·
[Keybindings](#-keybindings) ·
[Customization](#-customization) ·
[Structure](#-structure)

</div>

---

## ✦ Overview

A complete desktop setup in one repository: from the login screen to the shell prompt, everything uses the same dark gothic palette and thin borders.

| | |
|---|---|
| **WM** | Hyprland 0.57+, configured in Lua (`hyprland.lua`) |
| **Bar** | Waybar + eww volume mixer |
| **Lock screen** | hyprlock, styled after the SDDM theme |
| **Login** | SDDM, `blackmetal` theme |
| **Launcher** | rofi, with monochrome icons generated automatically |
| **Terminal** | kitty |
| **Notifications** | dunst |
| **Wallpapers** | awww |
| **GTK / cursor** | `hypr-dots-black`, `Breeze-Rin` icons |
| **Shell** | zsh + oh-my-zsh + powerlevel10k |
| **Font** | JetBrains Mono Nerd Font |

## ✦ Palette

The kitty colour scheme ("Gothic Cathedral") is the base for the rest of the setup.

| | name | hex |
|---|---|---|
| ![](https://placehold.co/18x18/080708/080708.png) | Black stone (background) | `#080708` |
| ![](https://placehold.co/18x18/c4c0c4/c4c0c4.png) | Old silver (foreground) | `#c4c0c4` |
| ![](https://placehold.co/18x18/7f263c/7f263c.png) | Dark wine | `#7f263c` |
| ![](https://placehold.co/18x18/a8324d/a8324d.png) | Bright wine | `#a8324d` |
| ![](https://placehold.co/18x18/5b526e/5b526e.png) | Muted violet | `#5b526e` |
| ![](https://placehold.co/18x18/765367/765367.png) | Dusty mauve | `#765367` |
| ![](https://placehold.co/18x18/9b9180/9b9180.png) | Bone | `#9b9180` |
| ![](https://placehold.co/18x18/806b58/806b58.png) | Bronze | `#806b58` |

## ✦ Installation

> Arch Linux only (`pacman` is required). Run as a regular user, not with `sudo`.
> The config needs Hyprland 0.57 or newer; the old `hyprland.conf` format is no longer used.

### From the repository

```bash
git clone https://github.com/freed0my/hypr-blackmetal-dots.git
cd hypr-blackmetal-dots
./install.sh
```

### Single file

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
2. Moves your old configs to `~/.dots-backup-<date>` and copies the new ones.
3. Installs the GTK theme, cursor and SDDM theme into `/usr/share`, and enables `sddm` and `NetworkManager`.
4. Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting.
5. Generates monochrome rofi icons for installed applications.

When it finishes, reboot and pick the **Hyprland** session in SDDM.

## ✦ Customization

> [!IMPORTANT]
> **Monitors.** The config assumes `DP-1` 1920x1080@240 with `HDMI-A-1` to its left. If yours differ, edit the `MONITORS` section in `~/.config/hypr/hyprland.lua` and `"output"` in `~/.config/waybar/config`. To list your monitors, run `hyprctl monitors`.

> [!NOTE]
> **NVIDIA.** The installer does not install graphics drivers.

- **Hyprland:** `~/.config/hypr/hyprland.lua`. Check it after editing with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
- **Terminal colours:** `~/.config/kitty/themes/blackmetal.conf`
- **Temperature in Waybar:** `hwmon-path-abs` in `~/.config/waybar/config` points to this machine's sensor. Set it to yours if the module stays empty.
- **Transparency:** `Super + U` makes kitty opaque, `Super + Shift + U` restores the default, `Super + Shift + I` sets 0.9.

## ✦ Keybindings

<details open>
<summary><b>General</b></summary>

| keys | action |
|---|---|
| `Super + Q` / `Super + Enter` | terminal (kitty) |
| `Alt + X` | launcher (rofi) |
| `Super + E` | file manager (Thunar) |
| `Super + C` | close window |
| `Alt + F` | fullscreen |
| `Super + Space` | toggle floating |
| `Super + L` | lock screen (hyprlock) |
| `Super + V` | screenshot region to clipboard |
| `Super + Shift + Print` | screenshot screen to clipboard |
| `Super + S` | scratchpad |
| `Super + Shift + K` | exit Hyprland |
| `Alt + Shift` | switch keyboard layout (us / ru) |

</details>

<details open>
<summary><b>Windows and workspaces</b></summary>

| keys | action |
|---|---|
| `Alt + 1…5` | workspaces 1–5 (DP-1) |
| `Super + 1…5` | workspaces 6–10 (HDMI-A-1) |
| `Super + Shift + 1…5` | move window to 1–5 |
| `Ctrl + Shift + 1…5` | move window to 6–10 |
| `Super + arrows` | move focus |
| `Super + Shift + arrows` | move window |
| `Super + Ctrl + arrows` | resize window |

</details>

## ✦ Structure

```
install.sh        installer
sync.sh           system → dots/, then translates and validates the config
i18n.sed          English text for the Russian comments and labels in the configs
bundle.sh         install.sh + dots/ → single file rin-hypr-dots.sh
dots/home/        everything copied into ~
dots/system/      GTK theme, cursor, SDDM theme (installed into /usr/share)
```

## ✦ Updating the repository

For maintainers, on your own machine after changing configs:

```bash
./sync.sh                      # copy current configs into dots/
git add -A && git commit -m "update" && git push
./bundle.sh                    # build rin-hypr-dots.sh
gh release create v$(date +%Y.%m.%d) rin-hypr-dots.sh --title "$(date +%F)" --notes ""
```

---

<div align="center">
<sub>Made by <a href="https://github.com/freed0my">freed0my</a></sub>
</div>
