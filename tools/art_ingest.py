"""Add finished art to the game in one command: check quality, crop, install, log. No reading of the art docs needed.

  python tools/art_ingest.py add  <image> <key> [--kind cg|battle|map|portrait] [--force] [--anchor top|bottom] [--face X Y --head H]
  python tools/art_ingest.py batch <list.txt>      # one "<image path> <key> [kind]" per line (quote paths with spaces)
  python tools/art_ingest.py inbox                 # every image in pics/inbox/ (file name = key), moved to pics/inbox/_done when installed
  python tools/art_ingest.py flush                 # regenerate ART-NEEDS / ART-PROMPTS / SOURCES, mark the log done
  python tools/art_ingest.py status                # how many images are waiting for a flush

What `add` does: (1) kind from the key (art.json / story / scenario / card ids) unless --kind; (2) quality check — hard fail when
too small / blank, warnings for blur, dark, wrong shape (--force installs anyway); (3) crop cg / battle to 16:9 (centre, or
--anchor top|bottom), portraits are only re-saved; (4) writes pics/source/<dir>/<key>.jpg and the pics/art.json entry (an existing
portrait keeps its face / head framing); (5) builds the game copy and appends a line to pics/ART-LOG.md.
The docs are NOT regenerated per image — run `flush` after ~20 (add / status print the count and say when it is time).
"""
from __future__ import annotations

import argparse
import datetime
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

import numpy as np
sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
PICS = ROOT / "pics"
LOG = PICS / "ART-LOG.md"
DATA = ROOT / "godot" / "data"
FLUSH_AT = 20
SECTION = {"cg": "cgs", "battle": "battles", "map": "maps", "portrait": "portraits", "relic": None}  # a relic icon has no art.json entry
SRC_DIR = {"cg": "cg", "battle": "battles", "map": "map"}
TARGET = 16 / 9  # cg / battle are cropped to this (portraits and the wide chapter maps are kept as they are)
MIN_H = {"cg": 480, "battle": 480, "map": 480, "portrait": 400, "relic": 128}  # hard fail below
SOFT_H = {"cg": 560, "battle": 560, "map": 560, "portrait": 560, "relic": 256}  # warn below


def _art() -> dict:
    return json.loads((PICS / "art.json").read_text("utf-8"))


def infer_kind(key: str) -> str | None:
    sys.path.insert(0, str(ROOT / "tools"))
    import art_prompts  # a key with a portrait prompt (even one with no card yet: a childhood version, an emperor…) is a portrait

    if key in art_prompts.PORTRAITS:
        return "portrait"
    art = _art()
    if key in json.loads((DATA / "cards.json").read_text("utf-8")).get("relics", {}):
        return "relic"
    for kind, sec in SECTION.items():
        if sec and key in art.get(sec, {}):
            return kind
    cards = json.loads((DATA / "cards.json").read_text("utf-8"))
    if key in cards.get("scenarios", {}):
        return "battle"
    if key in cards.get("cards", {}) or key in cards.get("enemies", {}):
        return "portrait"
    story = json.loads((DATA / "story.json").read_text("utf-8"))
    if key in [q["id"] for q in story["quests"]]:
        return "map"
    text = (DATA / "story.json").read_text("utf-8") + (DATA / "endings.json").read_text("utf-8") + (ROOT / "tools" / "art_prompts.py").read_text("utf-8")
    if re.search(r'"%s"' % re.escape(key), text):
        return "cg"
    return None


def quality(im: Image.Image, kind: str) -> tuple[list[str], list[str]]:
    """(hard problems, warnings)"""
    bad, warn = [], []
    w, h = im.size
    if h < MIN_H[kind]:
        bad.append(f"太小 {w}×{h}（至少高 {MIN_H[kind]}）")
    elif h < SOFT_H[kind]:
        warn.append(f"分辨率偏低 {w}×{h}")
    g = np.asarray(im.convert("L").resize((640, max(1, round(640 * h / w)))), dtype=np.float32)
    if g.std() < 12:
        bad.append("几乎是纯色 / 空白")
    if g.mean() < 25:
        warn.append("整体过暗")
    lap = g[1:-1, 1:-1] * 4 - g[:-2, 1:-1] - g[2:, 1:-1] - g[1:-1, :-2] - g[1:-1, 2:]
    sharp = float(lap.var())
    if sharp < 25:
        warn.append(f"偏模糊（锐度 {sharp:.0f}）")
    if kind in ("cg", "battle"):
        r = w / h
        if abs(r / TARGET - 1) > 0.25:
            lost = (1 - min(r, TARGET) / max(r, TARGET)) * 100
            warn.append(f"比例 {r:.2f} 离 16:9 较远，裁剪会丢掉 {lost:.0f}% 的画面")
    return bad, warn


def crop(im: Image.Image, kind: str, anchor: str) -> Image.Image:
    if kind in ("portrait", "map"):  # a chapter map is an ultra-wide scroll (3200x1080): never cropped
        return im
    w, h = im.size
    if abs(w / h / TARGET - 1) < 0.02:
        return im
    if w / h > TARGET:  # too wide: trim the sides
        nw = round(h * TARGET)
        x = (w - nw) // 2
        return im.crop((x, 0, x + nw, h))
    nh = round(w / TARGET)  # too tall: trim top / bottom
    y = {"top": 0, "bottom": h - nh}.get(anchor, (h - nh) // 2)
    return im.crop((0, y, w, y + nh))


HEAD = "# 美术入库记录\n\n`python tools/art_ingest.py add <图> <key>` 自动追加一行；`- [ ]` = 已入库、还没汇总进需求文档，`flush` 之后变 `- [x]`。\n"


def knock_out_backdrop(im: Image.Image, tol: int = 28) -> Image.Image:
    """Turn the near-white backdrop (reachable from the border) transparent, with a soft 1px edge."""
    from PIL import ImageDraw, ImageFilter

    small = im.convert("RGB")
    w, h = small.size
    marker = (255, 0, 255)
    work = small.copy()
    for pt in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]:
        if sum(work.getpixel(pt)) > 3 * (255 - tol):
            ImageDraw.floodfill(work, pt, marker, thresh=tol * 2)
    mask = np.all(np.asarray(work) == np.array(marker), axis=-1)
    try:  # white pockets enclosed by the object (inside a bow, behind a flag's pole): large pure-white areas go too
        from scipy import ndimage

        pure = np.all(np.asarray(small) >= 250, axis=-1) & ~mask
        lab, n = ndimage.label(pure)
        if n:
            sizes = ndimage.sum(pure, lab, range(1, n + 1))
            big = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s >= max(1500, w * h // 1800)])
            mask = mask | big
    except ImportError:
        pass
    alpha = Image.fromarray(np.where(mask, 0, 255).astype("uint8")).filter(ImageFilter.GaussianBlur(1.2))
    out = im.convert("RGBA")
    out.putalpha(alpha)
    return out


def log_line(text: str) -> None:
    cur = LOG.read_text("utf-8") if LOG.exists() else HEAD
    LOG.write_text(cur.rstrip("\n") + "\n" + text + "\n", "utf-8", newline="\n")


def pending() -> int:
    return LOG.read_text("utf-8").count("- [ ] ") if LOG.exists() else 0


def rebuild() -> None:  # (relics are copied straight in by add_one)
    from sanguo import art

    art.build()
    art.build_maps()
    art.build_maps(out=art.CG_OUT, section="cgs", height=art.BATTLE_H)
    art.build_maps(out=art.BATTLE_OUT, section="battles", height=art.BATTLE_H)


def add_one(src: Path, key: str, kind: str | None, force: bool, anchor: str, face=None, head=None) -> bool:
    kind = kind or infer_kind(key)
    if kind is None:
        print(f"✗ {key}: 不知道是什么图，加 --kind cg|battle|map|portrait")
        return False
    if not src.exists():
        print(f"✗ {key}: 找不到 {src}")
        return False
    im = Image.open(src)
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        bg = Image.new("RGBA", im.size, (246, 243, 234, 255))
        bg.alpha_composite(im)
        im = bg
    im = im.convert("RGB")
    bad, warn = quality(im, kind)
    if bad and not force:
        print(f"✗ {key} ({src.name}): " + "；".join(bad) + "  —— 加 --force 强制入库")
        return False
    if kind == "relic":  # a transparent icon: keep the alpha, shrink to 512, copy into the game
        icon = Image.open(src).convert("RGBA")
        if np.asarray(icon)[..., 3].min() == 255:  # a flat picture (white backdrop): make the backdrop transparent
            icon = knock_out_backdrop(icon)
        icon.thumbnail((512, 512), Image.LANCZOS)
        for d in (PICS / "source" / "relics", DATA / "art" / "relics"):
            d.mkdir(parents=True, exist_ok=True)
            icon.save(d / f"{key}.png")
        warn = [w for w in warn if "分辨率" not in w] if icon.size[1] >= 256 else warn
        ph = PICS / "relic_placeholders.json"  # the key is real art now
        if ph.exists():
            keys = [k for k in json.loads(ph.read_text("utf-8")) if k != key]
            ph.write_text(json.dumps(keys, ensure_ascii=False), "utf-8")
        log_line(f"- [ ] {datetime.date.today()} relic `{key}` ← {src.name} · {'ok' if not warn else '⚠ ' + '；'.join(warn)}")
        print(f"✓ {key} [relic]  {'ok' if not warn else '⚠ ' + '；'.join(warn)}")
        return True
    out = crop(im, kind, anchor)
    cfg = _art()
    sec = SECTION[kind]
    e = cfg[sec].get(key, {})
    if kind == "portrait":
        card = json.loads((DATA / "cards.json").read_text("utf-8")).get("cards", {}).get(key, {})
        rel = e.get("src") or f"source/{'soldiers' if card.get('rarity') == 'N' else 'generals'}/{key}.jpg"
        if e and "Gemini" not in str(e.get("license", "")):  # an old public-domain / stock picture is being replaced: its framing, licence and folder no longer apply
            rel = f"source/{'soldiers' if card.get('rarity') == 'N' else 'generals'}/{key}.jpg"
            for stale in ("face", "head", "source", "artist", "license"):
                e.pop(stale, None)
    else:
        rel = f"source/{SRC_DIR[kind]}/{key}.jpg"
    dst = PICS / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    out.save(dst, quality=93)
    e["src"] = rel
    e["license"] = e.get("license") or "用户提供（Gemini 生成）"
    default_frame = kind == "portrait" and "face" not in e and not face
    if kind == "portrait":
        e.setdefault("face", [0.5, 0.22])
        e.setdefault("head", 0.22)
        if face:
            e["face"] = list(face)
        if head:
            e["head"] = head
        e.pop("placeholder", None)
    cfg[sec][key] = e
    (PICS / "art.json").write_text(json.dumps(cfg, ensure_ascii=False, indent=2) + "\n", "utf-8", newline="\n")
    flags = "；".join(warn) if warn else "ok"
    if warn:
        flags = "⚠ " + flags
    if bad:
        flags = "强制：" + "；".join(bad) + (" ；" + "；".join(warn) if warn else "")
    if default_frame:
        flags += " ；取景用默认值，需看一眼调 face/head（--face X Y --head H）"
    cropped = "" if out.size == im.size else f" 裁 {im.size[0]}×{im.size[1]}→{out.size[0]}×{out.size[1]}"
    log_line(f"- [ ] {datetime.date.today()} {kind} `{key}` ← {src.name}{cropped} · {flags}")
    print(f"✓ {key} [{kind}]{cropped}  {flags}")
    return True


def main(argv=None) -> None:
    ap = argparse.ArgumentParser(prog="art_ingest")
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("add")
    a.add_argument("image")
    a.add_argument("key")
    a.add_argument("--kind", choices=list(SECTION))
    a.add_argument("--force", action="store_true")
    a.add_argument("--anchor", choices=["top", "center", "bottom"], default="center")
    a.add_argument("--face", nargs=2, type=float)
    a.add_argument("--head", type=float)
    b = sub.add_parser("batch")
    b.add_argument("list")
    b.add_argument("--force", action="store_true")
    sub.add_parser("inbox")
    sub.add_parser("flush")
    sub.add_parser("status")
    args = ap.parse_args(argv)
    if args.cmd == "add":
        if add_one(Path(args.image), args.key, args.kind, args.force, args.anchor, args.face, args.head):
            rebuild()
    elif args.cmd == "batch":
        n = 0
        for line in Path(args.list).read_text("utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                parts = [p.strip('"') for p in shlex.split(line, posix=False)]
                if len(parts) >= 2 and add_one(Path(parts[0]), parts[1], parts[2] if len(parts) > 2 else None, args.force, "center"):
                    n += 1
        if n:
            rebuild()
        print(f"{n} 张入库")
    elif args.cmd == "inbox":
        box = PICS / "inbox"
        box.mkdir(exist_ok=True)
        done = box / "_done"
        done.mkdir(exist_ok=True)
        files = sorted(f for f in box.iterdir() if f.is_file() and f.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp"))
        n = 0
        for f in files:
            if add_one(f, f.stem, None, False, "center"):
                f.replace(done / f.name)
                n += 1
        if n:
            rebuild()
        print(f"{n}/{len(files)} 张入库（没通过的还留在 pics/inbox/）" if files else "pics/inbox/ 里没有图")
    elif args.cmd == "flush":
        rebuild()
        subprocess.run([sys.executable, str(ROOT / "tools" / "art_prompts.py")], check=True, cwd=ROOT)
        from sanguo import art

        art.write_needs()
        art.write_sources()
        if LOG.exists():
            LOG.write_text(LOG.read_text("utf-8").replace("- [ ] ", "- [x] "), "utf-8", newline="\n")
        print("需求文档已更新，记录已标记完成")
        return
    n = pending()
    print(f"待汇总 {n} 张" + (f"  → 够 {FLUSH_AT} 张了，跑 `python tools/art_ingest.py flush`" if n >= FLUSH_AT else ""))


if __name__ == "__main__":
    main()
