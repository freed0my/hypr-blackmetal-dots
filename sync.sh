#!/usr/bin/env bash
# Copies the current configs from this machine into dots/. Run after changes,
# then:  git add -A && git commit -m "..." && git push
set -euo pipefail
cd "$(dirname "$0")"
D="$PWD/dots"
rm -rf "$D"; mkdir -p "$D/home" "$D/system"/{themes,icons,sddm}

# what to copy from $HOME (paths relative to $HOME)
HOME_ITEMS=(
  .config/hypr
  .config/waybar
  .config/rofi
  .config/kitty
  .config/dunst
  .config/eww-mixer
  .config/gtk-3.0
  .config/gtk-4.0
  .config/xsettingsd
  .config/fastfetch
  .local/share/icons/Breeze-Rin
  .local/share/icons/waybar-tray
  .zshrc
  .p10k.zsh
)
# skip: backups, swap files, unused wallpapers/configs, caches, personal bookmarks
EXCL=(
  --exclude='*.bak' --exclude='*.bak-*' --exclude='*.bak?' --exclude='*.save' --exclude='*.save.*'
  --exclude='*-swp' --exclude='.*.kate-swp' --exclude='*.tar.gz'
  --exclude='breeze-icons.rcc' --exclude='icon-theme.cache'
  --exclude='.config/hypr/wallpaperr.jpg' --exclude='.config/hypr/bg2.jpg' --exclude='.config/hypr/wallpaper.jpg'
  --exclude='.config/hypr/hyprlandd.conf' --exclude='.config/hypr/hyprlockf.conf' --exclude='.config/waybar/configlegacy'
  --exclude='.config/rofi/menuu.rasi' --exclude='.config/rofi/menuuuuu.rasi'
  --exclude='.config/fastfetch/*.jpg' --exclude='.config/gtk-3.0/bookmarks'
)

: > "$D/home.list"
for it in "${HOME_ITEMS[@]}"; do
    [ -e "$HOME/$it" ] || { echo "skip (missing): $it"; continue; }
    rsync -a "${EXCL[@]}" --relative "$HOME/./$it" "$D/home/"
    echo "$it" >> "$D/home.list"
done

# wallpaper: awww has no cache on a fresh system — set it explicitly
sed -i 's#^exec-once = awww-daemon$#exec-once = awww-daemon\nexec-once = sleep 1 \&\& awww img ~/.config/hypr/black.jpg#' \
    "$D/home/.config/hypr/hyprland.conf"

# .zshrc: no twintaillauncher autostart, paths via $HOME, pyenv only if present
if [ -f "$D/home/.zshrc" ]; then
    sed -i -e '/twintaillauncher/d' \
           -e "s#'$HOME/miniconda3/bin/conda'#\"\$HOME/miniconda3/bin/conda\"#" \
           -e "s#\"$HOME/#\"\$HOME/#g" \
           -e 's#^eval "$(pyenv init -)"$#command -v pyenv >/dev/null \&\& eval "$(pyenv init -)"#' \
           "$D/home/.zshrc"
fi

cp -a /usr/share/themes/hypr-dots-black   "$D/system/themes/"
cp -a /usr/share/icons/hypr-dots-black    "$D/system/icons/"
cp -a /usr/share/sddm/themes/blackmetal   "$D/system/sddm/"
chmod -R u+rwX,go+rX,go-w "$D/system"
cat > "$D/system/sddm-theme.conf" <<'EOF'
[Theme]
Current=blackmetal
CursorTheme=Adwaita
CursorSize=24
EOF

echo "dots/ updated ($(du -sh "$D" | cut -f1))"
