# English text for the public repo: the configs on the machine have Russian comments/labels.
# sync.sh applies this to dots/. Each rule replaces one whole line and is safe to re-apply.
# If sync.sh reports leftover Cyrillic, add a rule for that line here.
s|^# Blackmetal — hyprlock в стиле SDDM-темы /usr/share/sddm/themes/blackmetal$|# Blackmetal — hyprlock styled after the SDDM theme /usr/share/sddm/themes/blackmetal|
s|^# Палитра: bg #080708 · surface #211D21 · frame #2D2D2D · text #C4C0C4$|# Palette: bg #080708 · surface #211D21 · frame #2D2D2D · text #C4C0C4|
s|^# Координаты рассчитаны на 1920x1080 (как Main\.qml)\. y > 0 — вверх\.$|# Coordinates assume 1920x1080 (same as Main.qml). y > 0 is up.|
s|^# font_size в hyprlock — в pt (≈ px × 0\.75), поэтому 14px из SDDM → 11\.$|# hyprlock font_size is in pt (≈ px × 0.75), so 14px from SDDM → 11.|
s|^# ═══ верхняя панель (острова как в waybar), центр по y = 540-10-17 = 513 ═══$|# ═══ top bar (islands like in waybar), center y = 540-10-17 = 513 ═══|
s|^# ── лого ──$|# ── logo ──|
s|^# ── часы ──$|# ── clock ──|
s|^# ── раскладка ──$|# ── layout ──|
s|^# ── сессия ──$|# ── session ──|
s|^# ═══ окно логина (как rofi): 416x106, рамка highlight — «активное окно» ═══$|# ═══ login window (like rofi): 416x106, highlight border — "active window" ═══|
s|^# ── строка пользователя (y = +21) ──$|# ── user row (y = +21) ──|
s|^# ── строка пароля (y = -21): подсветка surface, как фокус в SDDM ──$|# ── password row (y = -21): surface highlight, like focus in SDDM ──|
s|^# ── caps lock под окном ──$|# ── caps lock below the window ──|
s|^# текущие данные$|# current state|
s|^  # переворачиваем$|  # flip|
s|^  # возвращаем обратно$|  # restore|
s|^# печатает предупреждение, если включён Caps Lock (для hyprlock)$|# prints a warning when Caps Lock is on (for hyprlock)|
s|^        "tooltip-format": "{desc}\\nЛКМ — микшер · ПКМ — mute · СКМ — сменить вывод · колесо — громкость",$|        "tooltip-format": "{desc}\\nLMB — mixer · RMB — mute · MMB — switch output · wheel — volume",|
s|^/\* Рамки — как у окон Hyprland, цвета — kitty blackmetal (Gothic Cathedral) \*/$|/* Borders like Hyprland windows, colors from kitty blackmetal (Gothic Cathedral) */|
s|^/\* ── «острова» ─────────────────────────────── \*/$|/* ── "islands" ───────────────────────────── */|
s|^/\* ── лево ───────────────────────────────────── \*/$|/* ── left ───────────────────────────────────── */|
s|^    /\* глиф иконки в Nerd Font смещён вправо на 2px — компенсируем \*/$|    /* the Nerd Font icon glyph is shifted 2px right — compensate */|
s|^    /\* фикс\. ширина, чтобы левый блок = правому и часы визуально были по центру \*/$|    /* fixed width so the left block equals the right one and the clock looks centered */|
s|^    min-width: 168px; /\* 20 символов × 8\.4px \*/$|    min-width: 168px; /* 20 chars × 8.4px */|
s|^/\* ── центр ──────────────────────────────────── \*/$|/* ── center ────────────────────────────────── */|
s|^/\* ── право ──────────────────────────────────── \*/$|/* ── right ─────────────────────────────────── */|
s|^    # Если приложений с активным звуком нет$|    # If no apps are playing audio|
s|^        printf '%s\\n' "󰝟  Нет активных аудиопотоков" \|$|        printf '%s\\n' "󰝟  No active audio streams" \||
s|^# Перекрашивает иконки трея в палитру kitty blackmetal (как иконки rofi)$|# Recolors tray icons to the kitty blackmetal palette (like the rofi icons)|
s|^# и прописывает их в "tray": {"icons": \.\.\.} конфига waybar\.$|# and writes them into "tray": {"icons": ...} in the waybar config.|
s|^# Запускать, когда в трее появилась новая программа: ~/\.config/waybar/scripts/mono-tray\.py$|# Run when a new app shows up in the tray: ~/.config/waybar/scripts/mono-tray.py|
s|^# не перекрашивать (иконка меняется сама — уведомления и т\.п\.)$|# don't recolor (icon changes by itself — notifications etc.)|
s|^        print(f"оставлено как есть: {item_id}")$|        print(f"left as is: {item_id}")|
s|^            print(f"пропущено: {item_id} (нет иконки)")$|            print(f"skipped: {item_id} (no icon)")|
s|^# Открывает/закрывает микшер\. eww запускается без ~/\.config/gtk-3\.0/gtk\.css,$|# Opens/closes the mixer. eww runs without ~/.config/gtk-3.0/gtk.css|
s|^# чтобы глобальная GTK-тема (Thunar) не перебивала стиль микшера\.$|# so the global GTK theme (Thunar) doesn't override the mixer style.|
s|^# Переключает вывод звука на следующее устройство\.$|# Switches audio output to the next device.|
s|^# Состояние звука для eww: печатает JSON при каждом изменении (pactl subscribe)\.$|# Audio state for eww: prints JSON on every change (pactl subscribe).|
s|^    # потоки одного приложения объединяются в одну строку$|    # streams from the same app are merged into one row|
s|^    # схлопываем пачку событий в одно обновление$|    # collapse a burst of events into one update|
s|^      (label :class "empty" :visible {arraylength(audio\.apps) == 0} :text "тишина"))))$|      (label :class "empty" :visible {arraylength(audio.apps) == 0} :text "silence"))))|
s|^// В тон waybar: kitty blackmetal, рамки как у неактивных окон Hyprland$|// Matches waybar: kitty blackmetal, borders like inactive Hyprland windows|
s|^ \* Rofi — в стиле waybar$| * Rofi — waybar style|
s|^ \* Рамка как у неактивных окон Hyprland, цвета — kitty blackmetal$| * Border like inactive Hyprland windows, colors from kitty blackmetal|
s|^# Собирает тему иконок для rofi в палитре kitty blackmetal из иконок установленных приложений\.$|# Builds a rofi icon theme in the kitty blackmetal palette from installed apps' icons.|
s|^# Перезапускать после установки новых программ: ~/\.config/rofi/bin/mono-icons\.py$|# Re-run after installing new apps: ~/.config/rofi/bin/mono-icons.py|
s|^# Тени -> вино-лиловый, середина -> серебро, свет -> кость (kitty blackmetal)$|# Shadows -> wine-lilac, midtones -> silver, highlights -> bone (kitty blackmetal)|
s|^print(f"{done}/{len(icons)} иконок -> {OUT}")$|print(f"{done}/{len(icons)} icons -> {OUT}")|
s|^ \* Рамки как у неактивных окон Hyprland, прямые углы, плотные отступы\.$| * Borders like inactive Hyprland windows, square corners, tight padding.|
s|^/\* Контейнеры (pavucontrol и др\.) — убрать серый фон базовой темы \*/$|/* Containers (pavucontrol etc.) — remove the base theme's gray background */|
s|^/\* Ползунки громкости \*/$|/* Volume sliders */|
s|^/\* Индикатор уровня звука \*/$|/* Audio level meter */|
s|^/\* Выпадающие списки и переключатели \*/$|/* Dropdowns and switches */|
s|^/\* Waybar: без общего фона окна \*/$|/* Waybar: no window background */|
s|^# быстрые команды для управления zapret$|# shortcuts for managing zapret|
s|^    -- передать окружение Wayland в systemd/dbus — иначе xdg-desktop-portal-hyprland падает при входе$|    -- pass the Wayland environment to systemd/dbus, otherwise xdg-desktop-portal-hyprland crashes at login|
s|^-- Игнорировать запросы maximize от приложений (kitty разворачивал себя на весь экран)$|-- Ignore maximize requests from apps (kitty kept maximizing itself)|
s|^// Blackmetal — SDDM в стиле Hyprland rice (waybar-острова + rofi-окно)$|// Blackmetal — SDDM styled after the Hyprland rice (waybar islands + rofi window)|
s|^    // ── палитра (theme\.conf, с фолбэками) ─────────────────────$|    // ── palette (theme.conf, with fallbacks) ──────────────────|
s|^    // ── компоненты ────────────────────────────────────────────$|    // ── components ──────────────────────────────────────────|
s|^    // «остров» как в waybar$|    // "island" like in waybar|
s|^    // ── верхняя панель (как waybar) ───────────────────────────$|    // ── top bar (like waybar) ─────────────────────────────|
s|^    // скрытый ListView только чтобы достать имя сессии по индексу$|    // hidden ListView just to get the session name by index|
s|^    // выпадающий список сессий (в стиле rofi)$|    // session dropdown (rofi style)|
s|^    // ── окно логина (как rofi menu) ───────────────────────────$|    // ── login window (like rofi menu) ─────────────────────────|
s|^        // активное «окно» — светлая рамка, как col\.active_border$|        // active "window" — light border, like col.active_border|
s|^            // строка-пользователь$|            // user row|
s|^            // строка-пароль$|            // password row|
s|^    // клик мимо — закрыть попап$|    // click outside — close popup|
s|^# Пусто = просто чёрный фон, как в Hyprland (black\.jpg)$|# Empty = plain black background, as in Hyprland (black.jpg)|
