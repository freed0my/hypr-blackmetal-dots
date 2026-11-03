#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  rin · hypr blackmetal dots — single-file installer
#  Arch Linux. Run:  ./install.sh   (or  -y  for no prompts)
#  Runs from a clone of the repo. bundle.sh builds a single file
#  rin-hypr-dots.sh with the configs as an archive after the __PAYLOAD__ line.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

YES=0; SKIP_PKGS=0; SKIP_ZSH=0
for a in "$@"; do
    case "$a" in
        -y|--yes)      YES=1 ;;
        --no-pkgs)     SKIP_PKGS=1 ;;
        --no-zsh)      SKIP_ZSH=1 ;;
        -h|--help)
            echo "bash $0 [-y] [--no-pkgs] [--no-zsh]"
            echo "  -y         don't ask any questions"
            echo "  --no-pkgs  configs only, skip package installation"
            echo "  --no-zsh   don't touch zsh / oh-my-zsh"
            exit 0 ;;
    esac
done

c()   { printf '\e[1;37m%s\e[0m\n' "$*"; }
ok()  { printf '  \e[32m✓\e[0m %s\n' "$*"; }
warn(){ printf '  \e[33m!\e[0m %s\n' "$*"; }
ask() { [ "$YES" = 1 ] && return 0; read -rp "  $1 [Y/n] " r; [[ -z "$r" || "$r" =~ ^[YyДд] ]]; }

[ "$(id -u)" = 0 ] && { echo "Run as a regular user, not with sudo."; exit 1; }
command -v pacman >/dev/null || { echo "Arch Linux (pacman) is required."; exit 1; }

# ── packages ─────────────────────────────────────────────────
PKGS=(
  # hyprland and ecosystem
  hyprland hyprlock hyprsunset hyprshot hyprcursor
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit polkit-kde-agent
  # bar / notifications / launcher / wallpapers
  waybar dunst libnotify rofi wofi awww
  # terminal / files
  kitty thunar thunar-volman tumbler gvfs htop fastfetch
  # screenshots / clipboard
  grim slurp wl-clipboard cliphist wtype
  # audio
  pipewire pipewire-pulse wireplumber libpulse pavucontrol playerctl
  # network
  networkmanager network-manager-applet
  # login
  sddm qt6-declarative qt6-svg
  # fonts
  ttf-jetbrains-mono-nerd ttf-jetbrains-mono noto-fonts noto-fonts-emoji noto-fonts-cjk
  # themes / icons / cursors
  breeze breeze-icons breeze-cursors breeze-gtk gnome-themes-extra adwaita-icon-theme
  papirus-icon-theme nwg-look xsettingsd glib2
  # for scripts (mono-icons, mono-tray, eww-mixer)
  python python-gobject gtk3 imagemagick jq
  # misc
  git base-devel zsh xdg-user-dirs unzip
)
AUR_PKGS=(eww opentabletdriver)

install_pkgs() {
    c "→ Repo packages (${#PKGS[@]})"
    sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"
    ok "repo packages installed"

    local helper=""
    command -v paru >/dev/null && helper=paru
    command -v yay  >/dev/null && helper=yay
    if [ -z "$helper" ]; then
        c "→ Installing yay (AUR helper)"
        local t; t=$(mktemp -d)
        git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$t/yay-bin"
        (cd "$t/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$t"; helper=yay
    fi
    c "→ AUR: ${AUR_PKGS[*]}"
    "$helper" -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "some AUR packages failed — install manually: $helper -S ${AUR_PKGS[*]}"
}

# ── where to take files from────────────────────────────────────
BUNDLED=0   # bundle.sh sets this to 1
if [ "$BUNDLED" = 1 ]; then
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    LINE=$(awk '/^__PAYLOAD__$/{print NR+1; exit}' "$0")
    tail -n +"$LINE" "$0" | tar -xJ -C "$TMP"
    SRC="$TMP/dots"
else
    SRC="$(cd "$(dirname "$0")" && pwd)/dots"
    [ -f "$SRC/home.list" ] || { echo "$SRC not found — run from the repo directory."; exit 1; }
fi

c ""
c "  rin · hypr blackmetal dots"
c ""
echo "  Will install: Hyprland, hyprlock, waybar, rofi, kitty, dunst, eww mixer,"
echo "  hypr-dots-black GTK theme, Breeze-Rin icons, blackmetal SDDM theme, zsh + p10k."
echo "  Old configs will be saved to ~/.dots-backup-<date>."
echo
ask "Proceed?" || exit 0

[ "$SKIP_PKGS" = 0 ] && install_pkgs

# ── back up and copy user configs ──────────────────────────
BK="$HOME/.dots-backup-$(date +%Y%m%d-%H%M%S)"
c "→ Configs (backup in $BK)"
mkdir -p "$BK"
backup_copy() { # $1 = path relative to $HOME
    local rel="$1"
    if [ -e "$HOME/$rel" ] || [ -L "$HOME/$rel" ]; then
        mkdir -p "$BK/$(dirname "$rel")"
        mv "$HOME/$rel" "$BK/$rel"
    fi
    mkdir -p "$HOME/$(dirname "$rel")"
    cp -a "$SRC/home/$rel" "$HOME/$rel"
}
while IFS= read -r rel; do
    [ "$SKIP_ZSH" = 1 ] && [[ "$rel" == .zshrc || "$rel" == .p10k.zsh ]] && continue
    backup_copy "$rel"
done < "$SRC/home.list"

# paths /home/rin → current $HOME
grep -rlI "/home/rin" "$HOME/.config/waybar" "$HOME/.config/hypr" "$HOME/.config/rofi" \
    "$HOME/.config/eww-mixer" "$HOME/.zshrc" 2>/dev/null | while read -r f; do
    sed -i "s#/home/rin#$HOME#g" "$f"
done || true
chmod +x "$HOME"/.config/hypr/scripts/*.sh "$HOME"/.config/waybar/scripts/* \
         "$HOME"/.config/rofi/bin/* "$HOME"/.config/rofi/*.sh "$HOME"/.config/eww-mixer/scripts/* 2>/dev/null || true
ok "configs in place"

# ── system: GTK theme, cursor, SDDM ──────────────────────────
c "→ System themes (sudo required)"
sudo mkdir -p /usr/share/themes /usr/share/icons /usr/share/sddm/themes /etc/sddm.conf.d
sudo cp -a "$SRC/system/themes/hypr-dots-black"     /usr/share/themes/
sudo cp -a "$SRC/system/icons/hypr-dots-black"      /usr/share/icons/
sudo rm -rf /usr/share/sddm/themes/blackmetal
sudo cp -a "$SRC/system/sddm/blackmetal"            /usr/share/sddm/themes/
sudo chown -R root:root /usr/share/themes/hypr-dots-black /usr/share/icons/hypr-dots-black /usr/share/sddm/themes/blackmetal
sudo chmod -R u=rwX,go=rX /usr/share/themes/hypr-dots-black /usr/share/icons/hypr-dots-black /usr/share/sddm/themes/blackmetal
sudo install -m644 "$SRC/system/sddm-theme.conf" /etc/sddm.conf.d/10-blackmetal.conf
ok "GTK theme, cursor and SDDM theme installed"

# ── services ────────────────────────────────────────────────
if [ "$SKIP_PKGS" = 0 ]; then
    c "→ Services"
    sudo systemctl enable NetworkManager.service 2>/dev/null && ok "NetworkManager" || true
    # disable other display managers, if any
    for dm in gdm lightdm lxdm ly greetd; do
        if systemctl is-enabled "$dm.service" &>/dev/null; then sudo systemctl disable "$dm.service" && warn "disabled $dm"; fi
    done
    sudo systemctl enable sddm.service 2>/dev/null && ok "sddm" || true
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
    command -v otd-daemon >/dev/null && systemctl --user enable opentabletdriver.service 2>/dev/null || true
fi

# ── GTK settings ────────────────────────────────────────────
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'hypr-dots-black' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Breeze-Rin' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10' 2>/dev/null || true
xdg-user-dirs-update 2>/dev/null || true
fc-cache -f >/dev/null 2>&1 || true
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/Breeze-Rin" >/dev/null 2>&1 || true

# ── zsh: oh-my-zsh + powerlevel10k + plugins ────────────────
if [ "$SKIP_ZSH" = 0 ] && command -v zsh >/dev/null; then
    c "→ zsh"
    [ -d "$HOME/.oh-my-zsh" ] || git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    Z="$HOME/.oh-my-zsh/custom"
    [ -d "$Z/themes/powerlevel10k" ]           || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$Z/themes/powerlevel10k"
    [ -d "$Z/plugins/zsh-autosuggestions" ]     || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$Z/plugins/zsh-autosuggestions"
    [ -d "$Z/plugins/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$Z/plugins/zsh-syntax-highlighting"
    [ "$(basename "${SHELL:-}")" = zsh ] || chsh -s "$(command -v zsh)" || warn "chsh failed — run it yourself: chsh -s /usr/bin/zsh"
    ok "zsh ready"
fi

# ── rofi icons (generated from installed apps) ───
if command -v magick >/dev/null && [ -x "$HOME/.config/rofi/bin/mono-icons.py" ]; then
    c "→ Generating monochrome rofi icons"
    "$HOME/.config/rofi/bin/mono-icons.py" >/dev/null 2>&1 && ok "Rofi-Mono ready" || warn "mono-icons.py failed — run it manually later"
fi

echo
c "  Done ✓"
echo "  • Reboot — SDDM (blackmetal) will greet you, pick the Hyprland session."
echo "  • Monitors are set for DP-1 240Hz + HDMI-A-1: ~/.config/hypr/hyprland.conf (Monitor Setup section)"
echo "    and \"output\": \"DP-1\" in ~/.config/waybar/config — adjust if your hardware differs."
echo "  • Waybar tray icons: after launching your apps run ~/.config/waybar/scripts/mono-tray.py"
echo "  • Old configs backup: $BK"
exit 0
