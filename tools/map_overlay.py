"""Draw every square of a chapter over its map background, at the game's coordinates, to check them against the art.

Every route shows at once (a demo walk only reaches one), so a chapter can be checked square by square:

    python tools/map_overlay.py yecheng --out <dir>                 # the installed map -> <dir>/yecheng_overlay_<n>.jpg
    python tools/map_overlay.py yecheng --out <dir> --map <strip>   # a strip that isn't installed yet

Each picture is ~1300 game px wide. The red ring marks where a square's icon sits, its name plate under it.
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from map_guide import ROOT, chapter, curve, edges, on_route, square_pos  # noqa: E402
from map_strip import geometry  # noqa: E402

TILE = 1300
OVERLAP = 150


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("key")
    ap.add_argument("--out", required=True)
    ap.add_argument("--map", default=None)
    a = ap.parse_args()
    cfg, quest = chapter(a.key)
    x_min = cfg.get("x_min", 0)
    gw, gh = geometry(quest, x_min, cfg.get("x_max"))
    pos, sq = square_pos(quest, x_min, cfg.get("x_max"), a.key)
    if "route" in cfg:  # a route's own map: only that route's squares
        sq = {k: s for k, s in sq.items() if on_route(s, set(cfg["route"]))}
    src = Path(a.map) if a.map else ROOT / "godot/data/art/map" / f"{a.key}.jpg"
    im = Image.open(src).convert("RGB").resize((gw, gh), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    font = ImageFont.truetype(str(ROOT / "godot/data/fonts/body.ttf"), 15)
    for x, y in edges(sq):
        d.line(curve(pos[x], pos[y]), fill=(90, 70, 40), width=3)
    for k, s in sq.items():
        cx, cy = pos[k]
        d.ellipse((cx - 30, cy - 30, cx + 30, cy + 30), outline=(230, 30, 30), width=3)
        label = s.get("label") or k
        box = d.textbbox((cx, cy + 34), label, font=font, anchor="ma")
        d.rectangle((box[0] - 3, box[1] - 2, box[2] + 3, box[3] + 2), fill=(20, 20, 20))
        d.text((cx, cy + 34), label, font=font, fill=(255, 240, 200), anchor="ma")
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    n, left = 1, 0
    while True:
        right = min(gw, left + TILE)
        im.crop((left, 0, right, gh)).save(out / f"{a.key}_overlay_{n}.jpg", quality=85)
        print(f"{a.key}_overlay_{n}.jpg  game x {left}-{right}")
        if right >= gw:
            break
        left, n = right - OVERLAP, n + 1


if __name__ == "__main__":
    main()
