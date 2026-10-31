"""Stitch a long chapter's map background from per-location panels (pics/map_panels.json).

A chapter map is an ultra-wide strip (5000-9000 px wide, ~390 high in the game's 1280x720 canvas): one generated
picture stretched over it comes out blurry and mostly cropped. Instead each stretch of columns gets its own 21:9
panel; this script cover-fits every panel into its columns' rectangle, cross-fades the seams and writes one strip
whose aspect matches the map exactly (map_screen.gd sizes the background to the full chapter, see _bg_size).

    python tools/map_strip.py prologue_north        # -> pics/source/map/prologue_north_strip.jpg
    python tools/art_ingest.py add pics/source/map/prologue_north_strip.jpg prologue_north --kind map
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
# must match godot/scripts/ui/map_screen.gd
COL_W, LANE_H, MAP_TOP = 150, 104, 22
BLEND = 140  # px (game units) of cross-fade at each seam
MAX_W = 8192  # keep under the common mobile GPU texture limit
SCALE = 1.5  # output px per game px (crisp on phones above 720p)


def geometry(quest: dict, x_min: int, x_max: int | None):
    sq = [s for s in quest["squares"].values() if s["x"] >= x_min and (x_max is None or s["x"] <= x_max)]
    xs = [s["x"] for s in sq]
    ys = [s["y"] for s in sq]
    w = 180 + (max(xs) - x_min) * COL_W + 60
    h = max(360, MAP_TOP + 50 + (max(ys) - min(ys)) * LANE_H + 110)
    return w, h


def cover(im: Image.Image, w: int, h: int) -> Image.Image:
    k = max(w / im.width, h / im.height)
    r = im.resize((max(w, round(im.width * k)), max(h, round(im.height * k))), Image.LANCZOS)
    left = (r.width - w) // 2
    top = (r.height - h) // 2
    return r.crop((left, top, left + w, top + h))


def build(key: str) -> Path:
    cfg = json.loads((ROOT / "pics/map_panels.json").read_text(encoding="utf-8"))[key]
    story = json.loads((ROOT / "godot/data/story.json").read_text(encoding="utf-8"))
    quest = next(q for q in story["quests"] if q["id"] == cfg["quest"])
    x_min = cfg.get("x_min", 0)
    gw, gh = geometry(quest, x_min, cfg.get("x_max"))
    s = min(SCALE, MAX_W / gw)
    W, H, blend = round(gw * s), round(gh * s), round(BLEND * s)
    panels = sorted(cfg["panels"], key=lambda p: p["from"])
    # a panel starts half a column before its first column's centre
    edges = [0] + [round((90 + (p["from"] - x_min) * COL_W - COL_W / 2) * s) for p in panels[1:]] + [W]
    out = Image.new("RGB", (W, H))
    for i, p in enumerate(panels):
        l = max(0, edges[i] - (blend // 2 if i else 0))
        r = min(W, edges[i + 1] + (blend // 2 if i < len(panels) - 1 else 0))
        tile = cover(Image.open(ROOT / "pics" / p["src"]).convert("RGB"), r - l, H)
        mask = np.full((H, r - l), 255, np.uint8)
        if i:
            ramp = np.linspace(0, 255, min(blend, r - l), dtype=np.float32)
            mask[:, : ramp.size] = ramp.astype(np.uint8)
        out.paste(tile, (l, 0), Image.fromarray(mask, "L"))
    dest = ROOT / "pics/source/map" / f"{key}_strip.jpg"
    out.save(dest, quality=88)
    print(f"{key}: {len(panels)} panels -> {dest.relative_to(ROOT)} {W}x{H} (game {gw}x{gh})")
    return dest


if __name__ == "__main__":
    for k in sys.argv[1:] or ["prologue_north"]:
        build(k)
