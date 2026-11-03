#!/usr/bin/env python3
# Recolors tray icons to the kitty blackmetal palette (like the rofi icons)
# and writes them into "tray": {"icons": ...} in the waybar config.
# Run when a new app shows up in the tray: ~/.config/waybar/scripts/mono-tray.py
import json
import os
import re
import subprocess

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

OUT = os.path.expanduser("~/.local/share/icons/waybar-tray")
CONFIG = os.path.expanduser("~/.config/waybar/config")
SNI = "org.kde.StatusNotifierItem"
# don't recolor (icon changes by itself — notifications etc.)
SKIP = ("discord",)


def busctl(*args):
    r = subprocess.run(["busctl", "--user", "--json=short", *args], capture_output=True, text=True)
    return json.loads(r.stdout)["data"] if r.returncode == 0 else None


def prop(svc, path, name):
    return busctl("get-property", svc, path, SNI, name)


def icon_file(name, theme_path):
    if not name:
        return None
    if name.startswith("/"):
        return name if os.path.exists(name) else None
    if theme_path:
        for root, _, files in os.walk(theme_path):
            for f in files:
                if os.path.splitext(f)[0] == name:
                    return os.path.join(root, f)
    theme = Gtk.IconTheme.get_default()
    info = theme.lookup_icon(name, 64, 0)
    return info.get_filename() if info else None


def pixmap_file(pixmaps, dst):
    w, h, data = max(pixmaps, key=lambda p: p[0] * p[1])
    argb = bytes(data)
    rgba = bytearray(len(argb))
    rgba[0::4], rgba[1::4], rgba[2::4], rgba[3::4] = argb[1::4], argb[2::4], argb[3::4], argb[0::4]
    raw = dst + ".rgba"
    with open(raw, "wb") as f:
        f.write(rgba)
    subprocess.run(["magick", "-size", f"{w}x{h}", "-depth", "8", f"rgba:{raw}", dst], check=True)
    os.remove(raw)
    return dst


os.makedirs(OUT, exist_ok=True)
clut = os.path.join(OUT, "clut.png")
subprocess.run(["magick", "-size", "1x128", "gradient:#2B2228-#8C858C",
                "-size", "1x128", "gradient:#8C858C-#E0DCE0",
                "-append", "-rotate", "-90", clut], check=True)

items = busctl("get-property", "org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher",
               "org.kde.StatusNotifierWatcher", "RegisteredStatusNotifierItems") or []

with open(CONFIG) as f:
    cfg = json.load(f)
icons = cfg.setdefault("tray", {}).setdefault("icons", {})

for item in items:
    svc, _, path = item.partition("/")
    path = "/" + path if path else "/StatusNotifierItem"
    item_id = prop(svc, path, "Id")
    if not item_id:
        continue
    if item_id.lower().startswith(SKIP):
        icons.pop(item_id, None)
        print(f"left as is: {item_id}")
        continue
    safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", item_id)
    src_tmp = os.path.join(OUT, f"{safe}.src.png")
    src = icon_file(prop(svc, path, "IconName"), prop(svc, path, "IconThemePath"))
    if not src:
        pix = prop(svc, path, "IconPixmap")
        if not pix:
            print(f"skipped: {item_id} (no icon)")
            continue
        src = pixmap_file(pix, src_tmp)
    dst = os.path.join(OUT, f"{safe}.png")
    pre = ["-background", "none", "-density", "384"] if src.endswith((".svg", ".svgz")) else []
    subprocess.run(["magick", *pre, src, "-resize", "64x64",
                    "-colorspace", "Gray", "-colorspace", "sRGB",
                    "-channel", "RGB", clut, "-clut", "+channel", dst], check=True)
    if os.path.exists(src_tmp):
        os.remove(src_tmp)
    icons[item_id] = dst
    print(f"{item_id} -> {dst}")

os.remove(clut)
with open(CONFIG, "w") as f:
    f.write(json.dumps(cfg, ensure_ascii=False, indent=4) + "\n")
subprocess.run(["pkill", "-SIGUSR2", "-x", "waybar"])
