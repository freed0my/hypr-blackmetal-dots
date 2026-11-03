#!/usr/bin/env python3
# Builds a rofi icon theme in the kitty blackmetal palette from installed apps' icons.
# Re-run after installing new apps: ~/.config/rofi/bin/mono-icons.py
import configparser
import glob
import os
import shutil
import subprocess

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

THEME = "Rofi-Mono"
SIZE = 96
OUT = os.path.expanduser(f"~/.local/share/icons/{THEME}")
APPS = os.path.join(OUT, f"{SIZE}x{SIZE}", "apps")

dirs = [os.path.expanduser("~/.local/share/applications"),
        os.path.expanduser("~/.local/share/flatpak/exports/share/applications"),
        "/var/lib/flatpak/exports/share/applications",
        "/usr/share/applications"]

icons = set()
for d in dirs:
    for f in glob.glob(os.path.join(d, "*.desktop")):
        cp = configparser.ConfigParser(interpolation=None, strict=False)
        try:
            cp.read(f, encoding="utf-8")
            name = cp.get("Desktop Entry", "Icon", fallback="").strip()
        except Exception:
            continue
        if name and not name.startswith("/"):
            icons.add(name)

theme = Gtk.IconTheme()
theme.set_custom_theme("breeze")

shutil.rmtree(OUT, ignore_errors=True)
os.makedirs(APPS)
with open(os.path.join(OUT, "index.theme"), "w") as f:
    f.write(f"""[Icon Theme]
Name={THEME}
Comment=Desaturated app icons for rofi
Inherits=breeze,hicolor
Directories={SIZE}x{SIZE}/apps

[{SIZE}x{SIZE}/apps]
Size={SIZE}
MinSize=8
MaxSize=512
Type=Scalable
Context=Applications
""")

# Shadows -> wine-lilac, midtones -> silver, highlights -> bone (kitty blackmetal)
CLUT = os.path.join(OUT, "clut.png")
subprocess.run(["magick", "-size", "1x128", "gradient:#2B2228-#8C858C",
                "-size", "1x128", "gradient:#8C858C-#E0DCE0",
                "-append", "-rotate", "-90", CLUT], check=True)

done = 0
for name in sorted(icons):
    info = theme.lookup_icon(name, SIZE, 0)
    src = info.get_filename() if info else None
    if not src:
        for ext in ("png", "svg", "xpm"):
            p = f"/usr/share/pixmaps/{name}.{ext}"
            if os.path.exists(p):
                src = p
                break
    if not src:
        continue
    pre = ["-background", "none", "-density", "384"] if src.endswith((".svg", ".svgz")) else []
    r = subprocess.run(["magick", *pre, src, "-resize", f"{SIZE}x{SIZE}",
                        "-colorspace", "Gray", "-colorspace", "sRGB",
                        "-channel", "RGB", CLUT, "-clut", "+channel",
                        os.path.join(APPS, f"{name}.png")],
                       capture_output=True)
    if r.returncode == 0:
        done += 1

os.remove(CLUT)
print(f"{done}/{len(icons)} icons -> {OUT}")
