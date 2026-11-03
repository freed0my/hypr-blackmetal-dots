#!/usr/bin/env python3
# Audio state for eww: prints JSON on every change (pactl subscribe).
import json
import select
import subprocess


def pactl_json(*args):
    out = subprocess.run(["pactl", "-f", "json", *args], capture_output=True, text=True).stdout
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        return []


def percent(volume):
    vals = [int(ch["value_percent"].rstrip("%")) for ch in volume.values()]
    return round(sum(vals) / len(vals)) if vals else 0


def short(desc):
    for cut in (" Digital Stereo", " Analog Stereo", " High Definition Audio Controller", " HD Audio Controller"):
        desc = desc.replace(cut, "")
    return desc


def state():
    default = subprocess.run(["pactl", "get-default-sink"], capture_output=True, text=True).stdout.strip()
    master = {"vol": 0, "muted": False, "name": ""}
    for s in pactl_json("list", "sinks"):
        if s["name"] == default:
            master = {"vol": percent(s["volume"]), "muted": s["mute"], "name": short(s["description"])}
    # streams from the same app are merged into one row
    apps = {}
    for i in pactl_json("list", "sink-inputs"):
        p = i.get("properties", {})
        name = (p.get("application.name") or p.get("media.name") or "?").removesuffix(".exe")
        a = apps.setdefault(name, {"name": name, "ids": [], "vol": 0, "muted": True})
        a["ids"].append(str(i["index"]))
        a["vol"] = max(a["vol"], percent(i["volume"]))
        a["muted"] = a["muted"] and i["mute"]
    for a in apps.values():
        a["ids"] = " ".join(a["ids"])
    return {"master": master, "apps": list(apps.values())}


last = None

def emit():
    global last
    s = json.dumps(state(), ensure_ascii=False)
    if s != last:
        print(s, flush=True)
        last = s


emit()
proc = subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE, text=True)
while True:
    line = proc.stdout.readline()
    if not line:
        break
    if not any(k in line for k in ("sink", "server")):
        continue
    # collapse a burst of events into one update
    while select.select([proc.stdout], [], [], 0.05)[0]:
        if not proc.stdout.readline():
            break
    emit()
