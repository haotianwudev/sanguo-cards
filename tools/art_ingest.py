"""Add finished art to the game in one command: check quality, crop, install, log. No reading of the art docs needed.

  python tools/art_ingest.py add  <image> <key> [--kind cg|battle|map|portrait] [--force] [--anchor top|bottom] [--face X Y --head H]
  python tools/art_ingest.py batch <list.txt>      # one "<image path> <key> [kind]" per line (quote paths with spaces)
  python tools/art_ingest.py flush                 # regenerate ART-NEEDS / ART-PROMPTS / SOURCES, mark the log done
  python tools/art_ingest.py status                # how many images are waiting for a flush

What `add` does: (1) kind from the key (art.json / story / scenario / card ids) unless --kind; (2) quality check — hard fail when
too small / blank, warnings for blur, dark, wrong shape (--force installs anyway); (3) crop cg / battle / map to 16:9 (centre, or
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
SECTION = {"cg": "cgs", "battle": "battles", "map": "maps", "portrait": "portraits"}
SRC_DIR = {"cg": "cg", "battle": "battles", "map": "map"}
TARGET = 16 / 9  # cg / battle / map are cropped to this
MIN_H = {"cg": 480, "battle": 480, "map": 480, "portrait": 400}  # hard fail below
SOFT_H = {"cg": 560, "battle": 560, "map": 560, "portrait": 560}  # warn below


def _art() -> dict:
    return json.loads((PICS / "art.json").read_text("utf-8"))


def infer_kind(key: str) -> str | None:
    art = _art()
    for kind, sec in SECTION.items():
        if key in art.get(sec, {}):
            return kind
    cards = json.loads((DATA / "cards.json").read_text("utf-8"))
    if key in cards.get("scenarios", {}):
        return "battle"
    if key in cards.get("cards", {}) or key in cards.get("enemies", {}):
        return "portrait"
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
    if kind != "portrait":
        r = w / h
        if abs(r / TARGET - 1) > 0.25:
            lost = (1 - min(r, TARGET) / max(r, TARGET)) * 100
            warn.append(f"比例 {r:.2f} 离 16:9 较远，裁剪会丢掉 {lost:.0f}% 的画面")
    return bad, warn


def crop(im: Image.Image, kind: str, anchor: str) -> Image.Image:
    if kind == "portrait":
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


def log_line(text: str) -> None:
    cur = LOG.read_text("utf-8") if LOG.exists() else HEAD
    LOG.write_text(cur.rstrip("\n") + "\n" + text + "\n", "utf-8", newline="\n")


def pending() -> int:
    return LOG.read_text("utf-8").count("- [ ] ") if LOG.exists() else 0


def rebuild() -> None:
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
    out = crop(im, kind, anchor)
    cfg = _art()
    sec = SECTION[kind]
    e = cfg[sec].get(key, {})
    if kind == "portrait":
        rel = e.get("src") or f"source/generals/{key}.jpg"
    else:
        rel = f"source/{SRC_DIR[kind]}/{key}.jpg"
    dst = PICS / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    out.save(dst, quality=93)
    e["src"] = rel
    e["license"] = e.get("license") or "用户提供（Gemini 生成）"
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
