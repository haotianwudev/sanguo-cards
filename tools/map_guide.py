"""Layout sketches for chapter map panels, so landmarks land under the right squares.

For every panel in pics/map_panels.json this draws a 21:9 composition sketch at the panel's real game coordinates
(the same cover-fit tools/map_strip.py uses): the chapter's roads as the game draws them (curves between squares)
and one coloured blob per landmark ("spots": [[square id, what to draw], ...]) just above its square. The sketch is
passed to art_gen.py as the first reference together with a prompt that names each blob's colour, so the model
paints the 甄府 where the 甄府 squares are instead of anywhere.

    python tools/map_guide.py prologue_north            # sketches -> pics/inbox/_map_guides/, prints the prompts
    python tools/map_guide.py prologue_north --gen      # also generates every panel (art_gen, nano-banana-2)
    python tools/map_guide.py prologue_north --gen 3    # only panel 3
"""
import json
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
from map_strip import BLEND, COL_W, LANE_H, MAP_TOP, geometry  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "pics/inbox/_map_guides"
IW, IH = 3168, 1344  # nano-banana-2 21:9 at 2k
COLOURS = [("红色", (220, 60, 50)), ("蓝色", (50, 100, 220)), ("绿色", (40, 160, 70)), ("紫色", (150, 70, 190)),
           ("橙色", (240, 140, 30)), ("青色", (30, 170, 180)), ("粉色", (230, 110, 170)), ("黄色", (225, 200, 40))]

COMMON = ("中国传统国风手绘鸟瞰地图长卷中的一段，画风和后面几张参考图完全一样：淡彩水墨线稿、斜45度俯瞰、远山与云雾。"
          "画面一直铺满到四条边：绝对不要卷轴、不要卷轴木轴、不要纸张边缘、不要边框、不要留白条。"
          "左右两端要能和相邻画卷衔接。不要人物特写、不要任何文字、不要旗帜。")
SKETCH = ("第一张参考图是这幅画的构图草图，必须严格按它的位置作画：草图里浅褐色的粗线是道路，在同样的位置画成手绘的土路或大路（有车辙、有路边的草和石头，线条和整幅画一致，不要画成一条平涂的色带）；"
          "草图里每个彩色圆块标出一个地标的位置，在圆块所在的位置画出对应的地标（大小和圆块差不多）：{spots}。"
          "草图里空白的地方画开阔平坦的地面（原野、雪地或河滩），不要放建筑和高山。画面最上方一窄条可以画远山和天空。"
          "成品里绝对不能出现任何彩色圆点、色块、圆圈或草图线条——圆块只是告诉你位置，要用画出来的建筑和地形把它完全替换掉。")


def chapter(key):
    cfg = json.loads((ROOT / "pics/map_panels.json").read_text(encoding="utf-8"))[key]
    story = json.loads((ROOT / "godot/data/story.json").read_text(encoding="utf-8"))
    quest = next(q for q in story["quests"] if q["id"] == cfg["quest"])
    return cfg, quest


def square_pos(quest, x_min, x_max, key=""):
    sq = {k: s for k, s in quest["squares"].items() if s["x"] >= x_min and (x_max is None or s["x"] <= x_max)}
    min_y = min(s["y"] for s in sq.values())
    nudge = json.loads((ROOT / "godot/data/map_nudge.json").read_text(encoding="utf-8")).get(key, {})

    def at(k, s):  # same as map_screen._pos, hand nudges included
        dx, dy = (max(-70, min(70, v)) for v in nudge.get(k, [0, 0]))
        return (90 + (s["x"] - x_min) * COL_W + dx, MAP_TOP + 50 + (s["y"] - min_y) * LANE_H + dy)

    return {k: at(k, s) for k, s in sq.items()}, sq


def edges(sq):
    for k, s in sq.items():
        nx = s.get("next") or []
        nx = [nx] if isinstance(nx, str) else list(nx)
        nx += [o["goto"] for o in s.get("choose", []) if o.get("goto")]
        for t in dict.fromkeys(nx):
            if t in sq:
                yield k, t


def curve(a, b, n=24):
    pts = []
    for i in range(n + 1):
        t = i / n
        e = t * t * (3 - 2 * t)
        pts.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * e))
    return pts


def sketches(key):
    cfg, quest = chapter(key)
    x_min = cfg.get("x_min", 0)
    gw, gh = geometry(quest, x_min, cfg.get("x_max"))
    pos, sq = square_pos(quest, x_min, cfg.get("x_max"), key)
    panels = sorted(cfg["panels"], key=lambda p: p["from"])
    cuts = [0] + [90 + (p["from"] - x_min) * COL_W - COL_W / 2 for p in panels[1:]] + [gw]
    OUT.mkdir(parents=True, exist_ok=True)
    jobs = []
    for i, p in enumerate(panels):
        l = max(0, cuts[i] - (BLEND / 2 if i else 0))
        r = min(gw, cuts[i + 1] + (BLEND / 2 if i < len(panels) - 1 else 0))
        w, h = r - l, gh
        k = max(w / IW, h / IH)  # cover fit, as map_strip.cover does
        ox, oy = (IW * k - w) / 2, (IH * k - h) / 2

        def to_img(g):
            return ((g[0] - l + ox) / k, (g[1] + oy) / k)

        im = Image.new("RGB", (IW, IH), (246, 242, 232))
        d = ImageDraw.Draw(im)
        for a, b in edges(sq):
            pts = [to_img(q) for q in curve(pos[a], pos[b])]
            d.line(pts, fill=(185, 160, 120), width=int(16 / k), joint="curve")
        spot_words = []
        for j, (sid, what) in enumerate(p.get("spots", [])):
            name, rgb = COLOURS[j % len(COLOURS)]
            cx, cy = to_img((pos[sid][0], pos[sid][1] - 14))  # on the square: bigger than its icon, so it shows around it
            rad = 58 / k
            d.ellipse((cx - rad * 1.3, cy - rad, cx + rad * 1.3, cy + rad), fill=rgb)
            spot_words.append(f"{name}圆块处画{what}")
        guide = OUT / f"{Path(p['src']).stem}.png"
        im.save(guide)
        prompt = f"{cfg.get('season', '')}{p['scene']} " + SKETCH.format(spots="；".join(spot_words)) + COMMON
        jobs.append((p, guide, prompt))
    return cfg, jobs


def main():
    key = sys.argv[1]
    gen = "--gen" in sys.argv
    only = [int(a) for a in sys.argv[2:] if a.isdigit()]
    cfg, jobs = sketches(key)
    procs = []
    for n, (p, guide, prompt) in enumerate(jobs, 1):
        print(f"--- {n} {p['src']}\n{guide.relative_to(ROOT)}\n{prompt}\n")
        if gen and (not only or n in only):
            refs = [str(guide)] + [str(ROOT / r) for r in cfg.get("style_refs", [])]
            procs.append(subprocess.Popen([sys.executable, str(ROOT / "tools/art_gen.py"), "--key", Path(p["src"]).stem,
                                           "--size", "21:9", "--out", str(ROOT / "pics" / p["src"]), "--prompt", prompt,
                                           "--ref", *refs], cwd=ROOT))
    for pr in procs:
        pr.wait()


if __name__ == "__main__":
    main()
