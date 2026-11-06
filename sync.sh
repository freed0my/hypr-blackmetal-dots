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
  --exclude='.config/hypr/hyprland.conf*' --exclude='.config/hypr/hyprlandd.conf' --exclude='.config/hypr/hyprlockf.conf' --exclude='.config/waybar/configlegacy'
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
LUA="$D/home/.config/hypr/hyprland.lua"
[ -f "$LUA" ] || { echo "error: ~/.config/hypr/hyprland.lua not found"; exit 1; }
sed -i 's#^\( *\)hl\.exec_cmd("awww-daemon")$#&\n\1hl.exec_cmd("sleep 1 \&\& awww img ~/.config/hypr/black.jpg")#' "$LUA"
grep -q 'awww img' "$LUA" || { echo "error: awww-daemon autostart line not found in hyprland.lua"; exit 1; }

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

# English text for the public repo (see i18n.sed). Icon themes are skipped:
# their index.theme carries the vendor's own translations.
I18N_DIRS=("$D/home/.config" "$D/home/.zshrc" "$D/system/sddm")
grep -rlIP '[\x{0400}-\x{04FF}]' "${I18N_DIRS[@]}" | while IFS= read -r f; do
    sed -i -f i18n.sed "$f"
done
if left=$(grep -rnIP '[\x{0400}-\x{04FF}]' "${I18N_DIRS[@]}"); then
    echo "warning: untranslated lines, add them to i18n.sed:"
    echo "$left" | sed "s#^$D/##"
fi

# the config must parse before it ships
if ! Hyprland --verify-config -c "$LUA" 2>&1 | grep -qx 'config ok'; then
    Hyprland --verify-config -c "$LUA" 2>&1 | tail -n 20
    echo "error: hyprland.lua has errors"; exit 1
fi

echo "dots/ updated ($(du -sh "$D" | cut -f1))"
